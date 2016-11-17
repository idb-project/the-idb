class AddMachineFacts < ActiveRecord::Migration
  def change
    add_column :machines, :os_release, :string
  end
end
