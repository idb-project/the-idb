module V2
  class Inventories < Grape::API
    helpers V2::Helpers

    version 'v2'
    format :json

    resource :inventories do
      before do
        api_enabled!
        authenticate!
      end

      get do
        can_read!
        if params[:id] != nil
          i = Inventory.find_by id: params[:id]
          if i
            i
          else
            status 404
            {}
          end
        else
          Inventory.all
        end        
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
      PaperTrail.whodunnit = p["idb_api_token"] ? p["idb_api_token"] : request.headers["X-Idb-Api-Token"] ? request.headers["X-Idb-Api-Token"] : nil
      p = p.reject { |k| !Inventory.attribute_method?(k) }
      Inventory.create(p)
    end

    def self.inventory_update(p)
      PaperTrail.whodunnit = p["idb_api_token"] ? p["idb_api_token"] : request.headers["X-Idb-Api-Token"] ? request.headers["X-Idb-Api-Token"] : nil
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
