class LocationLevel < ActiveRecord::Base
  belongs_to :owner
  has_many :locations
  validates :name, presence: true, uniqueness: true
  validates :level, presence: true, uniqueness: true

  def orphaned?

    locations= Location.where(:location_level_id => @id)
    if locations.empty?
        return true
    end

    return false
  end

end
