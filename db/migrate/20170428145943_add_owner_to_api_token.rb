class AddOwnerToApiToken < ActiveRecord::Migration[5.0]
  def change
    add_column :api_tokens, :owner_id, :integer
  end
end
