class RemoveMacAddressUniqConstraint < ActiveRecord::Migration
  def change
    remove_index :nics, :mac
  end
end
