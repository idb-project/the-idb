class AddApidocsToCloudProviders < ActiveRecord::Migration[5.0]
  def change
    add_column :cloud_providers, :apidocs, :string
  end
end
