class FixupDescriptionColumns < ActiveRecord::Migration[4.2]
  def change
    change_column :machines, :description, :string
    change_column :networks, :description, :string
    change_column :owners, :description, :string

    change_column :machines, :description, :longtext
    change_column :networks, :description, :longtext
    change_column :owners, :description, :longtext
  end
end
