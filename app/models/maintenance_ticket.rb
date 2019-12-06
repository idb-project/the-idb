class MaintenanceTicket < ApplicationRecord
  belongs_to :maintenance_announcement
  has_and_belongs_to_many :machines
  has_many :owners, :through => :machines

  def format_body
    a = maintenance_announcement
    t = a.maintenance_template
    t.format_body(t.format_params(self))
  end

  def format_subject
    a = maintenance_announcement
    t = a.maintenance_template
    t.format_subject(t.format_params(self))
  end

  # def format_machines_fqdns
  #   machines.pluck(:fqdn).join(", ")
  # end

  # we only have one owner
  def owner
    owners.group(:id).first
  end

  def rt_queue
    if owner && !owner.rt_queue.blank?
        owner.rt_queue
    else
      IDB.config.rt.queue
    end
  end

  # get the email address, either the owners or the one set in the announcement
  def email
    if maintenance_announcement.email
      return maintenance_announcement.email
    end

    return owner.announcement_contact
  end

  private

end
