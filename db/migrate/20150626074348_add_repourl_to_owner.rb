class AddRepourlToOwner < ActiveRecord::Migration[4.2]
  def change
    add_column :owners, :repo_url, :string
  end
end
