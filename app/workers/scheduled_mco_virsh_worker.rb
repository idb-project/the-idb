class ScheduledMcoVirshWorker
  include Sidekiq::Worker

  unless IDB.config.mco.socket_path.blank?
    if Rails.env.production?
      include Sidetiq::Schedulable
      recurrence { hourly.minute_of_hour(30) }
    else
      Rails.logger.info 'Not running McoVirshCollectorService, only works in production.'
    end
  else
    Rails.logger.info 'Not running McoVirshCollectorService, disabled by config mco.socket_path.'
  end

  def perform
    unless IDB.config.mco.socket_path.blank?
      if Rails.env.production?
        McoVirshCollectorService.new.update_machines
      else
        Rails.logger.info 'Not running McoVirshCollectorService, only works in production.'
      end
    else
      Rails.logger.info 'Not running McoVirshCollectorService, disabled by config mco.socket_path.'
    end
  end
end
