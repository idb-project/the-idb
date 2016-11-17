class AddSwitchUrlToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :switch_url, :string
  end
end
