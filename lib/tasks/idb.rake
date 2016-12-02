namespace :idb do
  namespace :machines do
    desc 'Schedule update for all machines'
    task update: :environment do
      ScheduledMachineUpdateWorker.perform_async
    end
  end
end
