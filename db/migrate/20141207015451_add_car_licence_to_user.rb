class AddCarLicenceToUser < ActiveRecord::Migration
  def change
    add_column :users, :carLicence, :string
  end
end
