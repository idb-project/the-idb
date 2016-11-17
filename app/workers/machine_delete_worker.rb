class MachineDeleteWorker
  include Sidekiq::Worker

  def perform(fqdn, username)
    logger.info { "Process delete for #{fqdn}" }

    MachineDeleteMailer.delete_email(fqdn, username).deliver
  end
end
