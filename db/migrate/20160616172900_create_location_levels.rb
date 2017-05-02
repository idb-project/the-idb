class CreateLocationLevels < ActiveRecord::Migration[4.2]
  def change
    create_table :location_levels do |t|
      t.string :name
      t.string :description
      t.integer :level
    end
  end
end
