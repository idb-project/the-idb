class InventoryPresenter < Keynote::Presenter
  presents :inventory

  delegate :inventory_number, :name, :serial, :part_number, :purchase_date, :install_date,
           :warranty_end, :seller, :status_string, :comment, :location_id, :place, :active?, :category,
           to: :inventory

  def id
    inventory.id
  end

  def comment
	  TextileRenderer.render(inventory.comment) if inventory.comment
  end

  def id_or_inventory_number
    number = ""
    if inventory.inventory_number == "" || inventory.inventory_number.nil?
      number = inventory.id
    else
      number = inventory_number
    end
    number
  end

  def id_or_inventory_number_link
    link_to(k(inventory).id_or_inventory_number, inventory)
  end

  def name_link
    link_to(inventory.name, inventory)
  end

  def machine_link
    inventory.machine ? link_to(inventory.machine.fqdn, inventory.machine) : ""
  end

  def user
    inventory.user ? inventory.user.display_name : ""
  end

  def owner
    inventory.owner ? inventory.owner.display_name: ""
  end

  def location_link
    return "" unless inventory.location
    names = Array.new()
    inventory.location.self_and_ancestors.to_a.reverse.each do |item|
      names.push(link_to(item.name, item))
    end
    names.join(" → ").html_safe
  end

  def owner_link
    inventory.owner ? link_to(inventory.owner.name, inventory.owner) : ""
  end

  def machine_fqdn
    inventory.machine ? inventory.machine.fqdn : ""
  end

  def attachment_list
    return "none" if (inventory.attachments && inventory.attachments.size == 0)

    list = "<ul>"
    inventory.attachments.each do |att|
      list += "<li><a href='#{att.attachment.url}' target='_blank'>#{att.attachment_file_name}</a></li>"
    end
    list += "</ul>"
  end
end
