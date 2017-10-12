module V3
  class CloudProviders < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json

    resource :cloud_providers do
      before do
        api_enabled!
        authenticate!
        set_papertrail
        @owner = get_owner
      end

      route_param :rname, type: String, requirements: { name: /[a-zA-Z0-9.]+/ } do
        desc 'Get cloud provider by name',
          success: CloudProvider::Entity
        get do
          can_read!
          c = CloudProvider.owned_by(@owner).find_by_name params[:rname]
          error!('Not found', 404) unless c

          present c
        end

        desc 'Update a single cloud provider',
          params: CloudProvider::Entity.documentation,
          success: CloudProvider::Entity
        put do
          can_write!
          c = CloudProvider.owned_by(@owner).find_by_name params[:rname]
          error!('Not found', 404) unless c

          params.delete("rname")
          c.update_attributes(params)

          present c
        end

        desc 'Delete cloud provider by name'
        get do
          can_write!
          c = CloudProvider.owned_by(@owner).find_by_name params[:rname]
          error!('Not found', 404) unless c

          c.destroy!
        end
      end

      desc 'Return a list of cloud providers, possibly filtered', is_array: true,
                                                                  success: CloudProvider::Entity
      get do
        can_read!

        query = CloudProvider.owned_by(@owner).all
        params.delete('idb_api_token')
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(CloudProvider.where(CloudProvider.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!('Bad Request', 400)
        end

        present query
      end

      desc 'Create a new cloud provider',
        params: CloudProvider::Entity.documentation,
        success: CloudProvider::Entity
      post do
        can_write!

        c = CloudProvider.new(params)
        c.owner = @owner
        c.save!
        present c
      end
    end
  end
end
