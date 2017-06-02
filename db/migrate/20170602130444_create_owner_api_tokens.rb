class CreateOwnerApiTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :owner_api_tokens do |t|
      t.integer :api_token_id
      t.integer :owner_id
    end
  end
end
