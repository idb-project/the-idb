class MaintenanceRecord < ActiveRecord::Base
  acts_as_paranoid

  has_many :attachments, :dependent => :destroy
  belongs_to :machine
  belongs_to :user

  def self.default_scope
    if User.current.nil? || User.current.is_admin?
      nil
    else
      -> { where(machine: Machine.where(owner: User.current.owners.to_a)) }
    end
  end

  def user
    u = User.unscope(where: :deleted_at).find_by_id(user_id)
  end

  class Entity < Grape::Entity
    expose :machine, documentation: { type: "String", desc: "FQDN of maintained machine", param_type: "body" }
    expose :logfile, documentation: { type: "String", desc: "Logfile data" }
    expose :user, documentation: { type: "String", desc: "User loginname" }
    expose :created_at, documentation: { type: "String", desc: "Creation timestamp" }

    def machine
      m = Machine.find_by_id(object.machine_id)
      if m
        return m.fqdn
      end
      return ""
    end

    def user
      u = User.unscope(where: :deleted_at).find_by_id(object.user_id)
      if u
        return u.login
      end
      return ""
    end
  end
end
