class RenameUcsRoleToVmId < ActiveRecord::Migration[5.2]
  def change
    rename_column :machines, :ucs_role, :vm_id
  end
end
