class CreateApiTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :api_tokens do |t|
		t.string :token
		t.boolean :read
		t.boolean :write
    end
  end
end
