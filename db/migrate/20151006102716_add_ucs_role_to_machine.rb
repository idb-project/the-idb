class AddUcsRoleToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :ucs_role, :string
  end
end
