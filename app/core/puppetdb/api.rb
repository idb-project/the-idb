module Puppetdb
  class Api < ForeignApi
    TIMEOUT = IDB.config.puppetdb.api_timeout
  end
end
