class AddCommentToInventory < ActiveRecord::Migration[4.2]
  def change
    add_column :inventories, :comment, :text
  end
end
