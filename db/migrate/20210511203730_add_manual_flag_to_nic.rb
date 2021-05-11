class AddManualFlagToNic < ActiveRecord::Migration[5.2]
  def change
    add_column :nics, :manually_created, :boolean
  end
end
