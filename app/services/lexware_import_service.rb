class LexwareImportService < Struct.new(:logger)
  def import_file(filename)
    parser = Lexware::CSVParser.new(filename)

    parser.process.each do |customer|
      owner = Owner.where(customer_id: customer.customer_id).first

      if owner
        logger.info "Importing data for owner #{owner.name}"

        owner.update(data: customer.attributes)
      else
        logger.info "Owner with customer id #{customer.customer_id} not found"
      end
    end
  end
end
