module Oxidized
  class Api < ForeignApi
    TIMEOUT = IDB.config.oxidized.nil? ? 10 : IDB.config.oxidized.api_timeout
  end
end
