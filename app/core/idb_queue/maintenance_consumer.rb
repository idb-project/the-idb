require 'stomp'
require 'multi_json'

module IDBQueue
  class MaintenanceConsumer
    def initialize(config, logger)
      @config = config
      @logger = logger
      @connection = Stomp::Client.new(params)
      @queue = "/queue/#{@config.queue_maintenance}"
      @options = {
        'ack' => 'client',
        'activemq.prefetchSize' => 1,
        'activemq.exclusive' => true
      }
    end

    def subscribe
      @connection.subscribe(@queue, @options) do |msg|
        begin
          yield(IDBQueue::Message.new({
            headers: msg.headers,
            body: msg.body,
            command: msg.command
          }))

          @connection.ack(msg)
        rescue => e
          @logger.error(e)
        end
      end
    end

    def join
      @connection.join
    end

    def close
      @connection.close
    end

    private

    def host_params
      {
        :host => @config.host,
        :port => @config.port,
        :login => @config.user,
        :passcode => @config.password,
        :ssl => Stomp::SSLParams.new({
          :cert_file => @config.ssl_cert,
          :key_file => @config.ssl_key,
          :ts_files => @config.ssl_ca,
          :use_ruby_ciphers => true # Unbreaks JRuby
        })
      }
    end

    def params
      {
        :hosts => [host_params],
        :logger => @logger,
        :connect_headers => {
          :host => @config.vhost,
          :'accept-version' => '1.1',
          :'heart-beat' => '5000,5000',
        }
      }
    end
  end
end
