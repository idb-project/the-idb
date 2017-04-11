class RemoveMacAddressUniqConstraint < ActiveRecord::Migration[4.0]
  def change
    remove_index :nics, :mac
  end
end
