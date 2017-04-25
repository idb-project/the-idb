class CreateLocationHierarchies < ActiveRecord::Migration[4.2]
  def change
    create_table :location_hierarchies, :id => false do |t|
      t.integer  :ancestor_id, :null => false
      t.integer  :descendant_id, :null => false
      t.integer  :generations, :null => false
    end
  end
end
