module IDBQueue
  class Message
    include Virtus.model

    attribute :headers, Hash[String => String]
    attribute :body, String
    attribute :command, String

    def message_id
      headers['message-id']
    end

    def destination
      headers['destination']
    end

    def timestamp
      Time.at(headers['timestamp'].to_i)
    end
  end
end
