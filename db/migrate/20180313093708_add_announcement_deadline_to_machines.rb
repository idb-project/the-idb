class AddAnnouncementDeadlineToMachines < ActiveRecord::Migration[5.0]
  def change
    add_column :machines, :announcement_deadline, :integer
  end
end
