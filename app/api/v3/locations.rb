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
          desc 'Get location by id',
            success: Location::Entity
          get do
            l = Location.owned_by(@owner).find_by_id params[:id]
            error!('Not Found', 404) unless l

            l
          end

          desc 'Create a new child location',
            params: Location::Entity.documentation,
            success: Location::Entity
          post do
            can_write!

            parent = Location.owned_by(@owner).find_by_id params[:id]
            error!('Not Found', 404) unless parent

            # delete route param for id
            params.delete("id")
            # we set this manually
            params.delete("parent")

            child = Location.new(params)
            child.owner = @owner
            child.save!
            parent.add_child(child)
          end

          desc 'Update a location',
            params: Location::Entity.documentation,
            success: Location::Entity
          put do
            can_write!

            l = Location.owned_by(@owner).find_by_id params[:id]
            error!('Not Found', 404) unless l

            params.delete("id")

            l.update_attributes(params)
            l.save!
          end

          desc 'Delete a location'
          delete do
            can_write!
            l = Location.owned_by(@owner).find_by_id params[:id]
            error!('Not Found', 404) unless l
            l.destroy
            body false
          end
        end
      end

      resource :roots do
        desc 'Get the location roots',
          is_array: true,
          success: Location::Entity
        get do
          can_read!
          Location.owned_by(@owner).roots.sort_by(&:name)
        end

        desc 'Create a new location root',
          params: Location::Entity.documentation,
          success: Location::Entity
        post do
          can_write!

          l = Location.new(params)
          l.owner = @owner
          l.save!

          present l
        end
      end

      resource :levels do
        desc 'Get a list of all location levels, possibly filtered',
          is_array: true,
          success: LocationLevel::Entity
        get do
          can_read!

          query = LocationLevel.owned_by(@owner).all
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

      desc 'Return a list of locations, possibly filtered',
        is_array: true,
        success: Location::Entity
      get do
        can_read!

        if params['level']
          if LocationLevel.owned_by(@owner).find_by_level(params['level'])
            params[:location_level_id] = LocationLevel.owned_by(@owner).find_by_level(params['level']).id
          else
            return []
          end
        end
        params.delete 'level'

        query = Location.owned_by(@owner).all
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
