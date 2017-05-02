class CreateAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :attachments do |t|
      t.string :description
      t.string :attachment
      t.integer :inventory_id

      t.timestamps
    end
  end
end
