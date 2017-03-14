module V2
  class Inventories < Grape::API
    helpers V2::Helpers

    version 'v2'
    format :json

    resource :inventories do
      before do
        api_enabled!
        authenticate!
        PaperTrail.whodunnit = params["idb_api_token"] ? params["idb_api_token"] : request.headers["X-Idb-Api-Token"] ? request.headers["X-Idb-Api-Token"] : nil
      end

      get do
        can_read!

        x = nil
        case
        when params[:id]
          x = Inventory.find_by id: params[:id]
        when params[:number]
          x = Inventory.where inventory_number: params[:number]
        when params[:owner]
          x = Inventory.where "owner_id = ?", params[:owner]
        else
          x = Inventory.all
        end

        if not x 
          status 404
          return {}
        end

        status 200
        x
      end

      post do
        can_write!
        p = params.to_hash
        begin
          i = Inventories.inventory_create(p)
          status 200
          i
        rescue ActiveRecord::RecordInvalid => e
          Raven.capture_exception(e)
          status 409
          return {}
        rescue ActiveRecord::RecordNotUnique => e
          Raven.capture_exception(e)
          status 409
          return {}
        end
      end

      put do
        can_write!
        p = params.to_hash
        begin
          i = Inventories.inventory_update(p)
          status 200
          i
        rescue ActiveRecord::RecordInvalid => e
          Raven.capture_exception(e)
          status 409
          return {}
        rescue ActiveRecord::RecordNotUnique => e
          Raven.capture_exception(e)
          status 409
          return {}
        end
      end
    end

    def self.inventory_create(p)
      p = p.reject { |k| !Inventory.attribute_method?(k) }
      Inventory.create(p)
    end

    def self.inventory_update(p)
      p = p.reject { |k| !Inventory.attribute_method?(k) }
      inventory = Inventory.find_by id: p["id"]
      if inventory != nil
        inventory.update_attributes(p)
        inventory
      else
        error("No such inventory", 404)
      end
    end
  end
end
