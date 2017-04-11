class AddWikiUrlToOwner < ActiveRecord::Migration[4.0]
  def change
    add_column :owners, :wiki_page, :string
  end
end
