class FixMissingTypeForMachines < ActiveRecord::Migration[5.0]
  def change
    Machine.where(type: nil).each do |m|
      m.type = "Machine"
      m.save!
    end
  end
end
