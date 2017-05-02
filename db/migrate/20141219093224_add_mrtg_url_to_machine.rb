class AddMrtgUrlToMachine < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :mrtg_url, :string
  end
end
