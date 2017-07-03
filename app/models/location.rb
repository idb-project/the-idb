class Location < ActiveRecord::Base
  has_many :machines_feed_a, class_name: 'Machine', foreign_key: :power_feed_a
  has_many :machines_feed_b, class_name: 'Machine', foreign_key: :power_feed_b
  belongs_to :location_level
  belongs_to :owner

  validates :name, presence: true
  has_closure_tree parent_column_name: :location_id


  def level_string
    location_level.fetch(level, '')
  end

  def location_name
    names = Array.new()
    self_and_ancestors.to_a.reverse.each do |item|
      names.push(item.name)
    end
    names.join(" → ")
  end

  def has_parent?
    parent.nil? ? false : true
  end

  def sorted_children
    ls = Array.new()
    cs = children.sort_by { |child| child.name }
    cs.each do |child|
      ls << child
      ls.concat(child.sorted_children.flatten)
    end
    ls
  end

  def self.depth_traverse
      ls = Array.new()

      Location.roots.each do |r|
        ls.concat(r.sorted_children)
      end

      ls
  end
  
  class Entity < Grape::Entity
    expose :id, documentation: { type: "Integer", desc: "Id" }
    expose :name, documentation: { type: "String", desc: "Name" }
    expose :description, documentation: { type: "String", desc: "Description" }
    expose :parent, documentation: { type: "Integer", desc: "Parent location id" }
    expose :children, documentation: { type: "Integer", is_array: true, desc: "Child location ids" }
    expose :level, documentation: { type: "String", desc: "Location level" }
    
    def children
      object.children.map { |c| c.id }
    end

    def parent
      object.parent ? object.parent.id : nil
    end

    def level
      l = LocationLevel.find_by_id object.location_level_id
      l.level
    end
  end
end
