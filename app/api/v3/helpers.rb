module V3
  module Helpers
    extend Grape::API::Helpers

    def api_enabled!
      unless IDB.config.modules.api.v3_enabled
        error!("API disabled.", 501)
      end
     end

    def get_token
      if params[:idb_api_token]
        return params[:idb_api_token]
      elsif request.headers["X-Idb-Api-Token"]
        return request.headers["X-Idb-Api-Token"]
      else
        error!("Unauthorized.", 401)
      end
    end

    def authenticate!
      token = params[:idb_api_token] ? params[:idb_api_token] : request.headers["X-Idb-Api-Token"]
      if ApiToken.where("token = ?", token).empty?
        error!("Unauthorized.", 401)
      end
    end

    def can_read!
      token = params[:idb_api_token] ? params[:idb_api_token] : request.headers["X-Idb-Api-Token"]
      unless ApiToken.where("token = ?", token).first.read
        error!("Unauthorized.", 401)
      end
    end

    def can_write!
      token = params[:idb_api_token] ? params[:idb_api_token] : request.headers["X-Idb-Api-Token"]
      unless ApiToken.where("token = ?", token).first.write
        error!("Unauthorized.", 401)
      end
    end

    def set_papertrail
      PaperTrail.whodunnit = params[:idb_api_token] ? params[:idb_api_token] : request.headers["X-Idb-Api-Token"] ? request.headers["X-Idb-Api-Token"] : nil
    end
  end
end
