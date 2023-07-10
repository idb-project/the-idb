class EnhanceApiTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :api_tokens, :post_reports, :boolean
    add_column :api_tokens, :post_logs, :boolean
    add_reference :api_tokens, :machine
  end
end
