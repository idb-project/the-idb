module V3
  module Helpers
    extend Grape::API::Helpers

    def api_enabled!
      unless IDB.config.modules.api.v3_enabled
        error!("API disabled.", 501)
      end
    end

    def get_tokens
      unless request.headers["X-Idb-Api-Token"]
        error!("Unauthorized.", 401)
      end
      request.headers["X-Idb-Api-Token"].split(",").map{ |x| x.strip }
    end

    def authenticate!
      tokens = get_tokens
      tokens.each do |t|
        # puts t
        # puts ApiToken.find_by_token(t)
        if not ApiToken.find_by_token(t)
          error!("Unauthorized. 0", 401)
        end
      end
    end

    def can_read!
      tokens = get_tokens
      tokens.each do |t|
        unless ApiToken.find_by_token(t).read
          error!("Unauthorized. 1", 401)
        end
      end
    end

    def can_write!
      token = get_tokens.first.to_s
      unless ApiToken.find_by_token(token).write
        error!("Unauthorized. 2", 401)
      end
      ApiToken.find_by_token(token)
    end

    def get_owner
      token = get_tokens.first.to_s
      x = ApiToken.find_by_token token

      return Owner.find_by_id x.owner_id
    end

    def get_owners
      tokens = get_tokens
      # tokens.each do |t|
      #   puts "TOKEN: ", t, "OWNER:", Owner.find_by_id(ApiToken.find_by_token(t).owner_id)
      # end
      owners = tokens.map{ |t| Owner.find_by_id(ApiToken.find_by_token(t).owner_id) }
      owners.uniq
      owners
    end

    def set_papertrail
      PaperTrail.whodunnit = params[:idb_api_token] ? params[:idb_api_token] : request.headers["X-Idb-Api-Token"] ? request.headers["X-Idb-Api-Token"] : nil
    end
  end
end
