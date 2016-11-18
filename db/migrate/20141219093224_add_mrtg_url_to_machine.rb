class AddMrtgUrlToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :mrtg_url, :string
  end
end
