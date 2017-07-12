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
        @owner = get_owner
      end

      resource :id do
        route_param :id, type: Integer do
          desc 'Get location by id', success: Location::Entity
          get do
            l = Location.find_by_id params[:id]
            error!('Not Found', 404) unless l

            l
          end

          desc 'Create a new child location', success: Location::Entity
          params do
            requires :id, type: Integer
            requires :name, type: String, documentation: { type: "String", desc: "Name" }
            optional :description, type: String, documentation: { type: "String", desc: "Description" }
            requires :level, type: Integer, documentation: { type: "String", desc: "Location level" }
          end
          post do
            can_write!

            parent = Location.find_by_id params[:id]
            error!('Not Found', 404) unless parent

            p = declared(params).to_h
            child = Location.new(p)
            child.owner = @owner
            child.save!
            parent.add_child(child)
          end

          desc 'Update a location', success: Location::Entity
          params do
            requires :id, type: Integer
            requires :name, type: String, documentation: { type: "String", desc: "Name" }
            optional :description, type: String, documentation: { type: "String", desc: "Description" }
            requires :level, type: Integer, documentation: { type: "String", desc: "Location level" }
          end
          put do
            can_write!

            l = Location.find_by_id params[:id]
            error!('Not Found', 404) unless l

            p = declared(params).to_h
            l.update_attributes(p)
            l.save!
          end

          desc 'Delete a location'
          delete do
            can_write!
            l = Location.find_by_id params[:id]
            error!('Not Found', 404) unless l
            l.destroy
          end
        end
      end

      resource :roots do
        desc 'Get the location roots', is_array: true,
                                       success: Location::Entity
        get do
          can_read!
          Location.roots.sort_by(&:name)
        end

        # FIXME
        desc 'Create a new location root', success: Location::Entity
        params do
          requires :name, type: String, documentation: { type: "String", desc: "Name" }
          optional :description, type: String, documentation: { type: "String", desc: "Description" }
        end
        post do
          can_write!

          p = declared(params).to_h
          l = Location.new(p)
          l.owner = @owner
          l.save!

          l
        end
      end

      resource :levels do
        desc 'Get a list of all location levels, possibly filtered', is_array: true,
                                                                     success: LocationLevel::Entity
        get do
          can_read!

          query = LocationLevel.all
          params.delete('idb_api_token')
          params.each do |key, value|
            keysym = key.to_sym
            query = query.merge(LocationLevel.where(LocationLevel.arel_table[keysym].eq(value)))
          end

          begin
            query.any?
          rescue ActiveRecord::StatementInvalid
            error!('Bad Request', 400)
          end

          query
        end
      end

      desc 'Return a list of locations, possibly filtered', is_array: true,
                                                                  success: Location::Entity
      get do
        can_read!

        if params['level']
          if LocationLevel.find_by_level(params['level'])
            params[:location_level_id] = LocationLevel.find_by_level(params['level']).id
          else
            return []
          end
        end
        params.delete 'level'

        query = Location.all
        params.delete('idb_api_token')
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(Location.where(Location.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!('Bad Request', 400)
        end

        query
      end
    end
  end
end
