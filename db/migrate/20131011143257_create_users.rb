class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :login
      t.string :name
      t.string :email

      t.timestamps
    end
    add_index :users, :login, unique: true
  end
end
