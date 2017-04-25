class AddUnattendedUpgradesToMachine < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :unattended_upgrades, :boolean, default: false
    add_column :machines, :unattended_upgrades_blacklisted_packages, :text
    add_column :machines, :unattended_upgrades_reboot, :boolean, default: false
    add_column :machines, :unattended_upgrades_time, :string
    add_column :machines, :unattended_upgrades_repos, :text
  end
end
