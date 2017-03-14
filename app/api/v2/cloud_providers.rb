module V2
  class CloudProviders < Grape::API
    helpers V2::Helpers

    version 'v2'
    format :json

    resource :cloud_providers do
      desc "Returns cloud providers by id, name or owner."
      get do
          authenticate!
          can_read!
          unless IDB.config.modules.api.v2_enabled
            status 501
            return {}
          end

          m = nil
          case
          when params[:id]
            m = CloudProvider.find_by "id", params[:id]
          when params[:name]
            m = CloudProvider.where "name = ?", params[:name]
          when params[:owner]
            m = CloudProvider.where "owner_id = ?", params[:owner]
          else
            m = CloudProvider.all
            if not m
              status 404
              return {}
            end
          end

          status 200
          m
      end
    end
  end
end
