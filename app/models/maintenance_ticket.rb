class MaintenanceTicket < ApplicationRecord
  belongs_to :maintenance_announcement
  has_and_belongs_to_many :machines
  has_many :owners, :through => :machines

  def format
    a = maintenance_announcement
    t = a.maintenance_template
    t.format({date: a.date.strftime("%Y-%m-%d"), reason: a.reason, impact: a.impact, machines: format_machines_fqdns })
  end

  def format_machines_fqdns
    machines.pluck(:fqdn).join(", ")
  end
end
