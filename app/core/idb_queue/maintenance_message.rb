require 'virtus'

module IDBQueue
  class MaintenanceMessage
    class UserAttribute < Virtus::Attribute
      def coerce(value)
        User.new(value)
      end
    end

    class Base64String < Virtus::Attribute
      def coerce(value)
        return unless value
        value.unpack('m').first.force_encoding('utf-8')
      end
    end

    class User
      include Virtus.model

      attribute :login, String
      attribute :name, String
      attribute :email, String
    end

    include Virtus.model

    attribute :fqdn, String
    attribute :timestamp, Time
    attribute :screenlog, Base64String
    attribute :user, UserAttribute
    attribute :noservice, String
  end
end
