class UserDeleteWorker
  include Sidekiq::Worker

  def perform(username, operatorname)
    logger.info { "Process delete for #{username}" }

    UserDeleteMailer.delete_email(username, operatorname).deliver
  end
end
