class AddMaintenanceRecordToAttachments < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :maintenance_record_id, :integer
  end
end
