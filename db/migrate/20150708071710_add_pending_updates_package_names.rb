class AddPendingUpdatesPackageNames < ActiveRecord::Migration
  def change
    add_column :machines, :pending_updates_package_names, :text
  end
end
