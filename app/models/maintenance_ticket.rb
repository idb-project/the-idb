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

  private

  def format_params
    a = maintenance_announcement
    t = a.maintenance_template
    {begin_date: a.begin_date, end_date: a.end_date, reason: a.reason, impact: a.impact, machines: format_machines_fqdns }
  end
end
