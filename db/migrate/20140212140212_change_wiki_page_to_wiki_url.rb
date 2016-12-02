class ChangeWikiPageToWikiUrl < ActiveRecord::Migration
  def change
    remove_column :owners, :wiki_page
    add_column :owners, :wiki_url, :string
  end
end
