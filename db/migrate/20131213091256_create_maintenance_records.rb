class CreateMaintenanceRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :maintenance_records do |t|
      t.string :fqdn, index: true
      t.references :machine, index: true
      t.references :user, index: true
      t.binary :logfile, limit: 4294967295

      t.timestamps
    end

    add_index :maintenance_records, [:fqdn, :created_at], unique: true
  end
end
