class AddMachineToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :machine_id, :integer
  end
end
