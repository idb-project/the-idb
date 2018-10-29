module Oxidized
  class Api < ForeignApi
    TIMEOUT = IDB.config.oxidized.api_timeout
  end
end
