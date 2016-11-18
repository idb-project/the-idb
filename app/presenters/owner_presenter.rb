class OwnerPresenter < Keynote::Presenter
  use_html_5_tags

  presents :owner

  delegate :id, to: :owner

  def name_link
    link_to(owner.name, owner) if owner
  end

  def wiki_link
    link_to(owner.wiki_url, owner.wiki_url, {:title => owner.wiki_url, :target => "_blank"}) if owner.wiki_url
  end

  def repo_link
    link_to(owner.repo_url, owner.repo_url, {:title => owner.repo_url, :target => "_blank"}) if owner.repo_url
  end

  def description
    TextileRenderer.render(owner.description) if owner && owner.description
  end

  def machines_count
    owner.machines.count
  end

  def name
    owner.name if owner
  end

  def nickname
    owner.nickname if owner
  end

  def customer_id
    owner.customer_id if owner
  end

  def imported_data
    return if !owner.data || owner.data.empty?

    c = Lexware::Customer.new(owner.data)

    build_html do
      address do
        address_line(self, c.company)
        address_line(self, c.street)
        address_line(self, "#{c.zipcode} #{c.city}")
        address_line(self, c.country)
        address_line(self, c.email, "email: #{c.email}")
        address_line(self, c.phone, "phone: #{c.phone}")
      end
    end
  end

  def address_line(ctx, value, text = nil)
    unless value.blank?
      ctx.text(text || value)
      ctx.br
    end
  end

  def attachment_list
    return "none" if (owner.attachments && owner.attachments.size == 0)

    list = "<ul>"
    owner.attachments.each do |att|
      list += "<li><a href='#{att.attachment.url}' target='_blank'>#{att.attachment_file_name}</a></li>"
    end
    list += "</ul>"
  end

  def backup_size_sum
    sum = 0
    owner.machines.each do |machine|
      sum+= machine.backup_last_full_size unless machine.backup_last_full_size.blank?
      sum+= machine.backup_last_inc_size unless machine.backup_last_inc_size.blank?
      sum+= machine.backup_last_diff_size unless machine.backup_last_diff_size.blank?
    end
    if sum > 0
      if sum >= 1099511627776
        # more than 1 TB, convert to GB
        (sum/1024/1024/1024).to_s + " GB"
      elsif sum >= 1073741824
        number_to_human_size(sum, precision: 0)
      else
        # less than 1 GB, we do not really care in the owner overview
        "0..1 GB"
      end
    else
      ""
    end
  end
end
