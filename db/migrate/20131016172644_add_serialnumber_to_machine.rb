class AddSerialnumberToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :serialnumber, :string
  end
end
