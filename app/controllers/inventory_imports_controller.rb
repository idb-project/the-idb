class InventoryImportsController < ApplicationController
  def new
  end

  def create
    file = params.require(:inventory_import).require(:file)
    filename = Rails.root.join("tmp/inventory-import-#{file.original_filename}").to_s

    File.open(filename, 'w') do |f|
      f.write(file.read.force_encoding('utf-8'))
    end

    InventoryImportService.new(logger).import_file(filename)

    redirect_to inventories_path, notice: 'Import started'
  end
end
