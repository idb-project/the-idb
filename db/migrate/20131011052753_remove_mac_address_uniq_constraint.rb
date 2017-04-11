class RemoveMacAddressUniqConstraint < ActiveRecord::Migration[4.2]
  def change
    remove_index :nics, :mac
  end
end
