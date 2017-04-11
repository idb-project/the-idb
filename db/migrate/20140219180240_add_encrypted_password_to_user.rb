class AddEncryptedPasswordToUser < ActiveRecord::Migration[4.0]
  def change
    add_column :users, :password_digest, :string
  end
end
