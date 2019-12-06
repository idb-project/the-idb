class MaintenanceAnnouncement < ApplicationRecord
  belongs_to :maintenance_template
  belongs_to :user
  has_many :maintenance_tickets
  has_many :owners, :through => :maintenance_tickets
  has_many :machines, :through => :maintenance_tickets

  def ignore_vms?
    (ignore_vms && ignore_vms == true) ? true : false
  end

  def ignore_deadlines?
    (ignore_deadlines && ignore_deadlines == true) ? true : false
  end
end
