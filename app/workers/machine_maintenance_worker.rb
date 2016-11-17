class MachineMaintenanceWorker
  include Sidekiq::Worker

  def perform(json)
    message = IDBQueue::MaintenanceMessage.new(JSON.parse(json))

    logger.info { "Processing maintenance message for #{message.fqdn}" }

    MachineMaintenanceService.new.process_message(message)
  end
end
