class CreateMaintenanceTickets < ActiveRecord::Migration[5.0]
  def change
    create_table :maintenance_tickets do |t|
      t.integer :ticket_id
      t.datetime :date
      t.references :maintenance_announcement, foreign_key: true

      t.timestamps
    end
  end
end
