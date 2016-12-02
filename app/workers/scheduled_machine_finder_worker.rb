class ScheduledMachineFinderWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(0) }

  def perform
    MachineFinderService.new($redis).find_untracked_machines
  end
end
