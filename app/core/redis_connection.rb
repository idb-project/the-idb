require 'connection_pool'
require 'redis'
require 'redis-namespace'

class RedisConnection
  def initialize(config)
    @pool = ConnectionPool.new(pool_options(config)) do
      client = ::Redis.new(url: config.url)
      ::Redis::Namespace.new(config.namespace, redis: client)
    end
  end

  def connection(&block)
    @pool.with(&block)
  end

  private

  def pool_options(config)
    {timeout: config.pool_timeout, size: config.pool_size}
  end
end
