class DisallowNilForMachineFqdn < ActiveRecord::Migration
  def change
    change_column :machines, :fqdn, :string, null: false
  end
end
