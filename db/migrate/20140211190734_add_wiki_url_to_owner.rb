class AddWikiUrlToOwner < ActiveRecord::Migration
  def change
    add_column :owners, :wiki_page, :string
  end
end
