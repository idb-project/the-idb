class ChangeWikiPageToWikiUrl < ActiveRecord::Migration[4.2]
  def change
    remove_column :owners, :wiki_page
    add_column :owners, :wiki_url, :string
  end
end
