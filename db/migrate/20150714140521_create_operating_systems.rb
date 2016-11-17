class CreateOperatingSystems < ActiveRecord::Migration
  def change
    create_table :operating_systems do |t|
      t.string :name
      t.string :family
      t.string :releaseversion
      t.string :majorversion
      t.string :minorversion
      t.boolean :eol, default: true
      t.text :severity_class

      t.timestamps
    end
  end
end
