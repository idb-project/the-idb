module V2
  class CloudProviders < Grape::API
    helpers V2::Helpers

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

      desc "Returns a cloud provider by name."
      params do
        requires :name, type: String, desc: "cloud provider config name"
      end
      route_param :name do
        get do
          authenticate!
          can_read!
          unless IDB.config.modules.api.v2_enabled
            status 501
            return {}
          end

          CloudProvider.find_by name: params[:name]
        end
      end

    end

  end
end
