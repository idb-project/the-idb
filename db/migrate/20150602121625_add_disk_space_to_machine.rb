class AddDiskSpaceToMachine < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :diskspace, :bigint
  end
end
