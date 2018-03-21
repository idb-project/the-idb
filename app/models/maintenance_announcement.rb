class MaintenanceAnnouncement < ApplicationRecord
  belongs_to :maintenance_template
  belongs_to :user
  has_many :maintenance_tickets
  has_many :owners, :through => :maintenance_tickets
  has_many :machines, :through => :maintenance_tickets
end
