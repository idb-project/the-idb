class ScheduledWarrantyReminderWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(8).minute_of_hour(0) }

  def perform
    WarrantyReminderWorker.perform_async
  end
end
