class LexwareImportsController < ApplicationController
  def new
  end

  def create
    file = params.require(:lexware_import).require(:file)
    filename = Rails.root.join("tmp/lexware-import-#{file.original_filename}").to_s

    File.open(filename, 'w') do |f|
      f.write(file.read.force_encoding('utf-8'))
    end

    LexwareImportWorker.perform_async(filename)

    redirect_to owners_path, notice: 'Import started'
  end
end
