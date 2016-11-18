class ChangeLevelForLocationLevelId < ActiveRecord::Migration
  def change
    add_column :locations, :location_level_id, :integer
  end
end
