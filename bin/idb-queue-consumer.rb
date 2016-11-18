$LOAD_PATH.unshift File.expand_path('../../', __FILE__)

require 'config/environment'
require 'logger'
require 'time'

$0 = 'idb-queue-consumer'

class LogFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    "[#{time.iso8601}] (#{$$}) #{msg2str(msg)}\n"
  end
end

if Rails.env.production?
  logdev = Rails.root.join('log/idb-queue-consumer.log')
else
  logdev = STDOUT
end

config = IDB.config.stomp
logger = Logger.new(logdev, 'daily')
logger.formatter = LogFormatter.new

logger.info("Connecting to message broker #{config.host}:#{config.port}/#{config.vhost}")
consumer = IDBQueue::MaintenanceConsumer.new(IDB.config.stomp, logger)

consumer.subscribe do |msg|
  logger.info("Received message #{msg.message_id} on #{msg.destination}")

  MachineMaintenanceWorker.perform_async(msg.body)
end

begin
  consumer.join
rescue Interrupt
end

logger.info("Shutting down...")
consumer.close
