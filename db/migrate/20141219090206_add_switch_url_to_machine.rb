class AddSwitchUrlToMachine < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :switch_url, :string
  end
end
