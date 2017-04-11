class AddSwitchUrlToMachine < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :switch_url, :string
  end
end
