class CreateMaintenanceAnnouncements < ActiveRecord::Migration[5.0]
  def change
    create_table :maintenance_announcements do |t|
      t.datetime :date
      t.text :reason
      t.text :impact
      t.references :maintenance_template, foreign_key: true

      t.timestamps
    end
  end
end
