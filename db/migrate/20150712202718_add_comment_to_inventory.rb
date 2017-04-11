class AddCommentToInventory < ActiveRecord::Migration[4.0]
  def change
    add_column :inventories, :comment, :text
  end
end
