class FixSingleTableInheritance < ActiveRecord::Migration[5.0]
  def up
    Machine.where(type: "Machine").each do |m|
      m.type = nil
      m.save!
    end
  end

  def down
    Machine.where(type: nil).each do |m|
      m.type = "Machine"
      m.save!
    end
  end
end
