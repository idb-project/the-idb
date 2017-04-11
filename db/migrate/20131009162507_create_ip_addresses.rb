class CreateIpAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :ip_addresses do |t|
      t.string :addr
      t.string :netmask
      t.string :family
      t.references :nic, index: true

      t.timestamps
    end
    add_index :ip_addresses, [:addr, :nic_id], unique: true
  end
end
