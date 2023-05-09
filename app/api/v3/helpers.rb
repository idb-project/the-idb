module V3
  module Helpers
    extend Grape::API::Helpers

    def debug_log_request
      request.url.inspect + " " + request.ip.inspect + " " + headers.inspect + " " + params.inspect
    end

    def api_enabled!
      unless IDB.config.modules.api.v3_enabled
        error!("API disabled.", 501)
      end
    end

    def get_tokens
      if request.headers["X-Idb-Api-Token"]
        return request.headers["X-Idb-Api-Token"].split(",").map{ |x| x.strip }
      elsif request.headers["X-E4a-License-Report-Machine-Id"]
        return request.headers["X-E4a-License-Report-Machine-Id"]
      else
        error!("Unauthorized, no tokens presented.", 401)
      end
    end

    def set_token(t)
      header "X-Idb-Api-Token", t
    end

    # select the first valid token for updating this item
    # return nil if no token matches
    def item_update_token(item)
      x = ApiToken.where(token: get_tokens, owner: item.owner, write: true)
      if x.first
        # just use the first one
        return x.first.token
      end
      return nil
    end

    def authenticate!
      tokens = get_tokens
      if ApiToken.where(token: tokens).empty?
        error!("Unauthorized, no matching tokens.", 401)
      end
    end

    def can_read!
      tokens = get_tokens
      if ApiToken.where(token: tokens, read: true).empty?
        error!("Unauthorized, not allowed to read.", 401)
      end
    end

    def can_write!
      tokens = get_tokens
      if ApiToken.where(token: tokens, write: true).empty?
        error!("Unauthorized, not allowed to write.", 401)
      end
      x.first
    end

    # get the owner of the first token
    def get_owner
      token = get_tokens.first.to_s
      x = ApiToken.find_by_token token
      unless x
        return nil
      end
      return Owner.find_by_id x.owner_id
    end

    def get_owners
      tokens = get_tokens
      Owner.joins(:api_tokens).where(api_tokens: { token: tokens })
    end

    def set_papertrail
      PaperTrail.request.whodunnit = params[:idb_api_token] ? params[:idb_api_token] : request.headers["X-Idb-Api-Token"] ? request.headers["X-Idb-Api-Token"] : nil
    end

    def logger
      API.logger
    end
  end
end
