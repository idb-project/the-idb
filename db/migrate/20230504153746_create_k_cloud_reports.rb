class CreateKCloudReports < ActiveRecord::Migration[5.2]
  def change
    create_table :k_cloud_reports do |t|
      t.string :ip
      t.string :reporter
      t.boolean :restart
      t.text :raw_data
      t.references :machine, index: true

      t.timestamps
    end
  end
end
