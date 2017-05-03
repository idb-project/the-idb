class AddUcsRoleToMachine < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :ucs_role, :string
  end
end
