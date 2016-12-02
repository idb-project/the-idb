class CreateLocationLevels < ActiveRecord::Migration
  def change
    create_table :location_levels do |t|
      t.string :name
      t.string :description
      t.integer :level
    end
  end
end
