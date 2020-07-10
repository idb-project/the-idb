Sidekiq.options[:concurrency] = 5

Sidekiq.configure_server do |config|
  config.redis = {url: IDB.config.redis.url, namespace: 'sidekiq:idb'}

  schedule_file = 'config/schedule.yml'
  if File.exists?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = {url: IDB.config.redis.url, namespace: 'sidekiq:idb'}
end
