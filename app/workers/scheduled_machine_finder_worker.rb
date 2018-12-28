class ScheduledMachineFinderWorker
  include Sidekiq::Worker

  def perform
    MachineFinderService.new($redis).find_untracked_machines
  end
end
