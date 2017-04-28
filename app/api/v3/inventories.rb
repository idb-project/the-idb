module V3
  class Inventories < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    resource :inventories do
      before do
        api_enabled!
        authenticate!
        set_papertrail
      end

      desc "Return a list of inventories, possibly filtered"
      get do
        can_read!

        query = Inventory.all
        params.delete("idb_api_token")
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(Inventory.where(Inventory.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!("Bad Request", 400)
        end

        query
      end

      desc 'Create a new inventory'
      post do
        can_write!
        p = params.reject { |k| !Inventory.attribute_method?(k) }
        p.merge(owner_id: token_owner_id)
        i = Inventory.create(p)
        i
      end

      desc "Get a inventory by inventory number"
      get ':number', requirements: {number: /[a-zA-Z0-9.]+/ } do
        i = Inventory.find_by_inventory_number params[:number]
        error!("Not found", 404) unless i

        i
      end

      desc "Update a single inventory"
      put ':number', requirements: {number: /[a-zA-Z0-9.]+/ } do
        i = Inventory.find_by_inventory_number params[:number]
        error!("Not found", 404) unless i

        p = params.reject { |k| !Inventory.attribute_method?(k) }

        i.update_attributes(p)

        i
      end
    end
  end
end