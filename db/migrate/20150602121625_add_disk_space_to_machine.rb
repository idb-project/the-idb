class AddDiskSpaceToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :diskspace, :bigint
  end
end
