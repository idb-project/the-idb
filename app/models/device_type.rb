class DeviceType
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :is_virtual, Boolean

  def self.types
    @__types = IDB.config.device_types.map {|t| new(t) }
  end

  def self.find(id)
    where(id: id).first
  end

  def self.where(query)
    # The implementation support only one argument for now!
    key, value = query.first

    return [] if value.nil?

    types.select do |type|
      type.respond_to?(key) && type.send(key) == value
    end
  end
end
