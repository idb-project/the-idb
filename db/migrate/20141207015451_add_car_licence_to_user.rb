class AddCarLicenceToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :carLicence, :string
  end
end
