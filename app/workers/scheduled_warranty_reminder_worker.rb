class ScheduledWarrantyReminderWorker
  include Sidekiq::Worker

  def perform
    WarrantyReminderWorker.perform_async
  end
end
