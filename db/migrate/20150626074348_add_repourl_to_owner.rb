class AddRepourlToOwner < ActiveRecord::Migration
  def change
    add_column :owners, :repo_url, :string
  end
end
