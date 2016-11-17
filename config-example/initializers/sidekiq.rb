Sidekiq.options[:concurrency] = 5

Sidekiq.configure_server do |config|
  config.redis = {url: IDB.config.redis.url, namespace: 'sidekiq:idb'}
end

Sidekiq.configure_client do |config|
  config.redis = {url: IDB.config.redis.url, namespace: 'sidekiq:idb'}
end
