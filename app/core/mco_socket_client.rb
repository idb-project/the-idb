require 'socket'
require 'json'
require 'virtus'

class McoSocketClient
  class Response
    include Virtus.model

    attribute :sender, String
    attribute :agent, String
    attribute :action, String
    attribute :statusmsg, String
    attribute :statuscode, Integer
    attribute :data, Hash
  end

  def initialize(path = IDB.config.mco.socket_path)
    @path = path
  end

  def rpc(agent, action, arguments = {})
    request = {agent: agent, action: action, arguments: arguments.to_hash}
    socket = open_socket(@path)

    return [] unless socket

    socket.write("#{JSON.dump(request)}\n")

    JSON.parse(socket.read).map do |response|
      Response.new(response)
    end
  rescue JSON::ParserError => e
    logger.error(e)
  end

  private

  def open_socket(path)
    UNIXSocket.new(path)
  rescue Errno::ENOENT => e
    Raven.capture_exception(e)
  end
end
