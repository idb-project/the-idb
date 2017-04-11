class DisallowNilForMachineFqdn < ActiveRecord::Migration[4.2]
  def change
    change_column :machines, :fqdn, :string, null: false
  end
end
