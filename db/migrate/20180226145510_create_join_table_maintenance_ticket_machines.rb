class CreateJoinTableMaintenanceTicketMachines < ActiveRecord::Migration[5.0]
  def change
    create_join_table :maintenance_tickets, :machines do |t|
      # t.index [:maintenance_ticket_id, :machine_id]
      # t.index [:machine_id, :maintenance_ticket_id]
    end
  end
end
