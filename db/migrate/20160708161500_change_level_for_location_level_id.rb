class ChangeLevelForLocationLevelId < ActiveRecord::Migration[4.2]
  def change
    add_column :locations, :location_level_id, :integer
  end
end
