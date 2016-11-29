class CreateCloudProviders < ActiveRecord::Migration
  def change
    create_table :cloud_providers do |t|
      t.belongs_to :owner
      t.string :name
      t.string :description
      t.text   :config, limit: 4294967295
    end
  end
end
