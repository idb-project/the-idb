class InventoryImportService < Struct.new(:logger)
  def import_file(filename)
    parser = InventoryImport::CSVParser.new(filename)

    parser.process.each do |inventory|
      i = Inventory.new
      i.inventory_number = inventory.inventory_number
      if i.inventory_number.starts_with?("-")
        i.inventory_number.slice!(0)
        i.inventory_number.slice!(i.inventory_number.length-1)
        i.status = 1
      end

      if (inventory.seller && inventory.seller.downcase.include?("sold")) || (inventory.machine && inventory.machine.downcase.include?("sold")) || (inventory.user && inventory.user.downcase.include?("sold")) || (inventory.name && inventory.name.downcase.include?("sold"))
        i.status = 2
      end

      i.name = inventory.name if inventory.name != "0" && inventory.name != "?"
      i.serial = inventory.serial if inventory.serial != "0" && inventory.serial != "?"
      i.part_number = inventory.part_number if inventory.part_number != "0" && inventory.part_number != "?"
      i.purchase_date = inventory.purchase_date if inventory.purchase_date != "0" && inventory.purchase_date != "?"
      i.warranty_end = inventory.warranty_end if inventory.warranty_end != "0" && inventory.warranty_end != "?"
      i.seller = inventory.seller if inventory.seller != "0" && inventory.seller != "?"
      i.comment = inventory.comment if inventory.comment != "0" && inventory.comment != "?"
      
      if inventory.machine && !inventory.machine.empty?
        m = Machine.where("fqdn LIKE ?", "#{inventory.machine}%")
        if m.empty? && inventory.machine != "0"
          i.comment.nil? ? i.comment = inventory.machine : i.comment << "\r\n"+inventory.machine
        else
          i.machine = m.first
        end
      end
      
      i.save
    end
  end
end
