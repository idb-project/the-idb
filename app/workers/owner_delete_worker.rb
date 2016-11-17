class OwnerDeleteWorker
  include Sidekiq::Worker

  def perform(ownername, username)
    logger.info { "Process delete for #{ownername}" }

    OwnerDeleteMailer.delete_email(ownername, username).deliver
  end
end
