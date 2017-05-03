module V3
  class CloudProviders < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    resource :cloud_providers do
      before do
        api_enabled!
        authenticate!
        set_papertrail
      end

      desc "Return a list of cloud providers, possibly filtered"
      get do
        can_read!

        query = CloudProvider.all
        params.delete("idb_api_token")
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(CloudProvider.where(CloudProvider.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!("Bad Request", 400)
        end

        query
      end

      desc 'Create a new cloud provider'
      post do
        can_write!
        p = params.reject { |k| !CloudProvider.attribute_method?(k) }
        c = CloudProvider.create(p)
        c
      end

      desc "Get cloud provider by name"
      get ':name', requirements: {number: /[a-zA-Z0-9.]+/ } do
        can_read!
        c = CloudProvider.find_by_name params[:name]
        error!("Not found", 404) unless c

        c
      end

      desc "Update a single cloud provider"
      put ':name', requirements: {name: /[a-zA-Z0-9.]+/ } do
        can_write!
        c = CloudProvider.find_by_inventory_number params[:name]
        error!("Not found", 404) unless c

        p = params.reject { |k| !CloudProvider.attribute_method?(k) }

        c.update_attributes(p)

        c
      end
    end
  end
end