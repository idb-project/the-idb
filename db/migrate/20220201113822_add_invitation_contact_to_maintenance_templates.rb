class AddInvitationContactToMaintenanceTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :maintenance_templates, :invitation_contact, :string
  end
end
