class AddSerialnumberToMachine < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :serialnumber, :string
  end
end
