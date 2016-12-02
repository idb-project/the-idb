class LexwareImportWorker
  include Sidekiq::Worker

  def perform(filename)
    LexwareImportService.new(logger).import_file(filename)
  end
end
