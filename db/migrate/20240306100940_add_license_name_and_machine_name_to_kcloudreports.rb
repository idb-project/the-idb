class AddLicenseNameAndMachineNameToKcloudreports < ActiveRecord::Migration[5.2]
  def change
    add_column :k_cloud_reports, :machine_name, :string
    add_column :k_cloud_reports, :license_name, :string
  end
end
