class MaintenanceRecord < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :machine
  belongs_to :user
end
