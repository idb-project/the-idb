class AddNameAndDescriptionToApiTokens < ActiveRecord::Migration[4.2]
  def change
    add_column :api_tokens, :name, :string
    add_column :api_tokens, :description, :string
  end
end
