module V2
  class CloudProviders < Grape::API
    helpers do
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
    end

    version 'v2'
    format :json

    resource :cloud_providers do
      desc "Return a list of all cloud providers"
      get do
        authenticate!
        can_read!
        unless IDB.config.modules.api.v2_enabled
          status 501
          return {}
        end

        p = params.to_hash

        unless p["owner"].to_i != 0
          CloudProvider.all
        else
          m = CloudProvider.where("owner_id = ?", p["owner"].to_i)
          if m.empty?
            status 404
            {}
          else
            m
          end
        end
      end
    end

  end
end
