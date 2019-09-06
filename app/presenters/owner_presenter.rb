class OwnerPresenter < Keynote::Presenter
  use_html_5_tags

  presents :owner

  delegate :id, :announcement_contact, to: :owner

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

    if IDB.config.modules.lexware_rt_crm_api && owner.data["addressCountry"]
      # data fetched from Lexware via RT CRM API
      c = Lexware::APICustomer.new(owner.data)
      build_html do
        address do
          address_line(self, c.companyName)
          address_line(self, c.addressStreet)
          address_line(self, "#{c.addressPostalcode} #{c.addressCity}")
          address_line(self, c.addressCountry)
          address_line(self, c.email, "email: #{c.email}")
        end
      end
    else
      # data from Lexware via importer
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
end
