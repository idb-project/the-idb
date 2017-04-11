class AddSerialnumberToMachine < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :serialnumber, :string
  end
end
