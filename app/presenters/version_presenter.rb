class VersionPresenter < Keynote::Presenter
  presents :version
  delegate :changeset, to: :version

  use_html_5_tags # For <style> html tags.

  def id
    version.id
  end

  def index
    version.index+1
  end

  def event
    version.event.humanize
  end

  def user
    return '?' unless version.whodunnit

    if version.whodunnit.to_i > 0 
      u = User.find_by_id(version.whodunnit.to_i)
      return u.display_name if u
    else
      t = ApiToken.find_by_token(version.whodunnit)
      return link_to(t.name, t) if t
    end
    return '?'
  end

  def show_link
    link_to('show diff', version_path(version))
  end

  def created_at
    version.created_at.localtime.strftime('%F %T')
  end

  def summary
    "Version #{version.index+1} by <strong>#{user}</strong> on #{created_at}".html_safe
  end

  def header_link(v)
    if version.item_type == "Machine"
      machine = Machine.find(version.item_id)
      link_to(machine.name, machine, :class => "brand")
    elsif version.item_type == "Owner"
      owner = Owner.find(version.item_id)
      link_to(owner.display_name, owner, :class => "brand")
    elsif version.item_type == "Network"
      network = Network.find(version.item_id)
      link_to(network.name, network, :class => "brand")
    elsif version.item_type == "Inventory"
      inventory = Inventory.find(version.item_id)
      link_to(inventory.name, inventory, :class => "brand")
    else
      "<span class='brand'>#{v.item_type} #{v.item_id}</span>".html_safe
    end
  end

  def diff_css
    build_html do
      style Diffy::CSS, type: 'text/css'
    end
  end

  def diff_html(changeset)
    Diffy::Diff.new(*changeset).to_s(:html).html_safe
  end

  def diff_text(changeset)
    Diffy::Diff.new(*changeset).to_s(:text).gsub("\n\\ No newline at end of file", "")
  end

  def diff_text_backup_type(changeset)
    out = Diffy::Diff.new(*changeset).to_s(:text)
    out.gsub!("0", Machine::BackupType[0])
    out.gsub!("1", Machine::BackupType[1])
    out.gsub!("2", Machine::BackupType[2])
    out.gsub!("3", Machine::BackupType[3])
    out.gsub("\n\\ No newline at end of file", "")
  end

  def diff_text_backup_brand(changeset)
    out = Diffy::Diff.new(*changeset).to_s(:text)
    out.gsub!("0", Machine::BackupBrand[0])
    out.gsub!("1", Machine::BackupBrand[1])
    out.gsub!("2", Machine::BackupBrand[2])
    out.gsub!("3", Machine::BackupBrand[3])
    out.gsub!("4", Machine::BackupBrand[4])
    out.gsub("\n\\ No newline at end of file", "")
  end

  def diff_text_device_type(changeset)
    out = Diffy::Diff.new(*changeset).to_s(:text)
    out.gsub!("1", DeviceType.find(1).name)
    out.gsub!("2", DeviceType.find(2).name)
    out.gsub!("3", DeviceType.find(3).name)
    out.gsub("\n\\ No newline at end of file", "")
  end

  def diff_text_owner(changeset)
    if (changeset)
      old = changeset[0] ? Owner.find_by_id(*changeset[0]).display_name : " ---"
      new = changeset[1] ? Owner.find_by_id(*changeset[1]).display_name : " ---"
      "-#{old}\r\n+#{new}"
    else
      ""
    end
  end

  def diff_text_location(changeset)
    if (changeset)
      old = changeset[0] ? Location.find_by_id(*changeset[0]).name : " ---"
      new = changeset[1] ? Location.find_by_id(*changeset[1]).name : " ---"
      "-#{old}\r\n+#{new}"
    else
      ""
    end
  end

  def diff_text_user(changeset)
    if (changeset)
      old = changeset[0] ? User.find_by_id(*changeset[0]).display_name : " ---"
      new = changeset[1] ? User.find_by_id(*changeset[1]).display_name : " ---"
      "-#{old}\r\n+#{new}"
    else
      ""
    end
  end

  def diff_text_machine(changeset)
    if (changeset)
      old = changeset[0] ? Machine.find_by_id(*changeset[0]).fqdn : " ---"
      new = changeset[1] ? Machine.find_by_id(*changeset[1]).fqdn : " ---"
      "-#{old}\r\n+#{new}"
    else
      ""
    end
  end

  def diff_inventory_status(changeset)
    if (changeset)
      old = changeset[0] ? InventoryStatus.find_by_id(*changeset[0]).name : " ---"
      new = changeset[1] ? InventoryStatus.find_by_id(*changeset[1]).name : " ---"
      "-#{old}\r\n+#{new}"
    else
      ""
    end
  end

  def changesets
    version.changeset.each do |attribute, changeset|
      yield(attribute.humanize, changeset)
    end
  end

  def mail_subject
    %([#{IDB.config.design.title}] #{version.item.class} "#{version.item.name}" #{version.event} by #{user})
  end

  def diff_html_machine(changeset)
    diff_html(changeset_values(changeset, Machine, "fqdn"))
  end

  def diff_html_owner(changeset)
    diff_html(changeset_values(changeset, Owner, "display_name"))
  end

  def diff_html_location(changeset)
    diff_html(changeset_values(changeset, Location, "location_name"))
  end

  def diff_html_status(changeset)
    diff_html(changeset_values(changeset, InventoryStatus, "name"))
  end

  def diff_html_user(changeset)
    diff_html(changeset_values(changeset, User, "display_name"))
  end

  def changeset_values(changeset, klass, attribute)
    if not changeset or changeset.size != 2
      return ["",""]
    end

    oldo = changeset[0] ? klass.find_by_id(changeset[0]) : nil
    newo = changeset[1] ? klass.find_by_id(changeset[1]) : nil

    old = oldo ? oldo.send(attribute) : ""
    new = newo ? newo.send(attribute) : ""
    return [old,new]
  end
end
