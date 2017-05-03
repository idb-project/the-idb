class LocationSerializer < ActiveModel::Serializer
  attributes :id,:name,:description,:parent,:children,:level

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
