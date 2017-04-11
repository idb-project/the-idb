class ChangeWikiPageToWikiUrl < ActiveRecord::Migration[4.0]
  def change
    remove_column :owners, :wiki_page
    add_column :owners, :wiki_url, :string
  end
end
