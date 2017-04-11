class AddCarLicenceToUser < ActiveRecord::Migration[4.0]
  def change
    add_column :users, :carLicence, :string
  end
end
