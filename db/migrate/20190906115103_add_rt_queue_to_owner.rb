class AddRtQueueToOwner < ActiveRecord::Migration[5.0]
  def change
    add_column :owners, :rt_queue, :string
  end
end
