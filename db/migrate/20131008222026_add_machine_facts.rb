class AddMachineFacts < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :os_release, :string
  end
end
