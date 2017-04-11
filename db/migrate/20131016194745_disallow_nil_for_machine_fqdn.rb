class DisallowNilForMachineFqdn < ActiveRecord::Migration[4.0]
  def change
    change_column :machines, :fqdn, :string, null: false
  end
end
