class AddCommentToInventory < ActiveRecord::Migration
  def change
    add_column :inventories, :comment, :text
  end
end
