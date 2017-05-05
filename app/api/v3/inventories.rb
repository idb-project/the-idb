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

      route_param :number do
        desc "Get a inventory by inventory number"
        get do
          can_read!
          i = Inventory.find_by_inventory_number params[:number]
          error!("Not found", 404) unless i

          i
        end

        desc "Update a single inventory"
        put do
          can_write!
          i = Inventory.find_by_inventory_number params[:number]
          error!("Not found", 404) unless i

          p = params.reject { |k| !Inventory.attribute_method?(k) }

          i.update_attributes(p)

          i
        end

        desc "Delete a inventory"
        delete do
          can_write!
          i = Inventory.find_by_inventory_number params[:number]
          error!("Not found", 404) unless i

          i.destroy
        end
      end

      desc "Return a list of inventories, possibly filtered"
      get do
        can_read!

        if params["machine"] 
          if Machine.find_by_fqdn(params["machine"])
            params[:machine_id] = Machine.find_by_fqdn(params["machine"]).id
          else
            return []
          end
        end
        params.delete "machine"

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
        i = Inventory.create(p)
        i
      end
    end
  end
end