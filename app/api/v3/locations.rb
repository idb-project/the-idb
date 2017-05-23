module V3
  class Locations < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json

    resource :locations do
      before do
        api_enabled!
        authenticate!
        set_papertrail
      end

      resource :id do
        route_param :id, type: Integer do
          desc "Get location by id", {
	    success: Location::Entity
	  }
          get do
            l = Location.find_by_id params[:id]
            error!("Not Found", 404) unless l

            l
          end

          # FIXME
          desc "Create a new child location", {
	    success: Location::Entity
	  }
          post do
          end

          # FIXME
          desc "Update a location", {
	    success: Location::Entity
	  }
          put do
          end

          # FIXME
          desc "Delete a location"
          delete do
          end
        end
      end

      resource :roots do
        desc "Get the location roots", {
	  is_array: true,
	  success: Location::Entity
	}
        get do
          can_read!
          Location.roots.sort_by {|l| l.name}
        end

        # FIXME
        desc "Create a new location root", {
	  success: Location::Entity
	}
        post do
        end

        # FIXME
        desc "Update a location root", {
	  success: Location::Entity
	}
        put do
        end

        # FIXME
        desc "Delete a location root"
        delete do
        end
      end

      resource :levels do
        desc "Get a list of all location levels, possibly filtered", {
	  is_array: true,
	  success: LocationLevel::Entity
	}
        get do
          can_read!

          query = LocationLevel.all
          params.delete("idb_api_token")
          params.each do |key, value|
            keysym = key.to_sym
            query = query.merge(LocationLevel.where(LocationLevel.arel_table[keysym].eq(value)))
          end

          begin
            query.any?
          rescue ActiveRecord::StatementInvalid
            error!("Bad Request", 400)
          end

          query
        end
      end  

      desc "Return a list of location levels, possibly filtered", {
	is_array: true,
	success: LocationLevel::Entity
      }
      get do
        can_read!

        if params["level"] 
          if LocationLevel.find_by_level(params["level"])
            params[:location_level_id] = LocationLevel.find_by_level(params["level"]).id
          else
            return []
          end
        end
        params.delete "level"

        query = Location.all
        params.delete("idb_api_token")
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(Location.where(Location.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!("Bad Request", 400)
        end

        query
      end
    end
  end
end