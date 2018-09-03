class MaintenanceTicket < ApplicationRecord
  belongs_to :maintenance_announcement
  has_and_belongs_to_many :machines
  has_many :owners, :through => :machines

  def format_body
    a = maintenance_announcement
    t = a.maintenance_template
    t.format_body(format_params)
  end

  def format_subject
    a = maintenance_announcement
    t = a.maintenance_template
    t.format_subject(format_params)
  end

  def format_machines_fqdns
    machines.pluck(:fqdn).join(", ")
  end

  # we only have one owner
  def owner
    owners.group(:id).first
  end

  # get the email address, either the owners or the one set in the announcement
  def email
    if maintenance_announcement.email
      return maintenance_announcement.email
    end

    return owner.announcement_contact
  end

  private

  def format_params
    a = maintenance_announcement
    t = a.maintenance_template
    p = { 
      begin_date: a.begin_date.to_formatted_s(:announcement_date),
      end_date: a.end_date.to_formatted_s(:announcement_date),
      begin_time: a.begin_date.to_formatted_s(:announcement_time),
      end_time: a.end_date.to_formatted_s(:announcement_time),
      begin_full: a.begin_date.to_formatted_s(:announcement_full),
      end_full: a.end_date.to_formatted_s(:announcement_full),
      reason: a.reason,
      impact: a.impact,
      machines: format_machines_fqdns,
      user: a.user.display_name 
    }

    # don't show machines in formatted ticket if we send to one address
    if maintenance_announcement.email
      p[:machines] = ""
    end
    
    p
  end
end
