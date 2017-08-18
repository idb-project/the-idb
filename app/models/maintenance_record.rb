class MaintenanceRecord < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :machine
  belongs_to :user

  def self.default_scope
    if User.current.nil? || User.current.is_admin?
      nil
    else
      -> { where(machine: Machine.where(owner: User.current.owners.to_a)) }
    end
  end
end
