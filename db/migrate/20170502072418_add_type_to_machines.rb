class AddTypeToMachines < ActiveRecord::Migration[5.0]
  def up
    add_column :machines, :type, :string

    Machine.where(device_type_id: nil).each do |m|
      m.type = "Machine"
      m.save!
    end

    Machine.where(device_type_id: 3).each do |m|
      m.type = "Switch"
      m.save!
    end

    Machine.where(device_type_id: 2).each do |m|
      m.type = "VirtualMachine"
      m.save!
    end

    remove_column :machines, :device_type_id
  end

  def down
    add_column :machines, :device_type_id, :integer

    Machine.all.each do |m|
      m.device_type_id = 1
      m.save!
    end

    Switch.all.each do |m|
      m.device_type_id = 3
      m.save!
    end

    VirtualMachine.all.each do |m|
      m.device_type_id = 2
      m.save!
    end

    remove_column :machines, :type
  end
end
