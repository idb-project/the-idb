class AddFurtherScFieldsToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :business_criticality, :string
    add_column :machines, :business_notification, :string
  end
end
