class AddMachineToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :machine_id, :integer
  end
end
