class AddNameAndDescriptionToApiTokens < ActiveRecord::Migration
  def change
    add_column :api_tokens, :name, :string
    add_column :api_tokens, :description, :string
  end
end
