class CloudProvider < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  belongs_to :owner

  def self.owned_by(o)
    where(owner: o)
  end

  def self.default_scope
    if User.current.nil? || User.current.is_admin?
      nil
    else
      -> { where(owner: User.current.owners.to_a) }
    end
  end
  
  class Entity < Grape::Entity
    expose :name, documentation: { type: "String", desc: "Cloud Provider name" }
    expose :description, documentation: { type: "String", desc: "Cloud Provider description" }
    expose :config, documentation: { type: "String", desc: "Cloud Provider configuration" }
    expose :apidocs, documentation: { type: "String", desc: "Link to API documentation for this Cloud Provider" }
  end
end
