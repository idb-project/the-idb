class LocationLevel < ActiveRecord::Base
  belongs_to :owner
  has_many :locations
  validates :name, presence: true, uniqueness: true
  validates :level, presence: true, uniqueness: true

  def self.owned_by(o)
    where(owner: o)
  end

  def orphaned?

    locations= Location.where(:location_level_id => @id)
    if locations.empty?
        return true
    end

    return false
  end

  class Entity < Grape::Entity
    expose :name, documentation: { type: "String", desc: "Name" }
    expose :level, documentation: { type: "Integer", desc: "Level" }
    expose :description, documentation: { type: "String", desc: "Description" }
  end
  
end
