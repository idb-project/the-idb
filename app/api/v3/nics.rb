module V3
  class Nics < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json

    resource :nics do
      before do
        api_enabled!
        authenticate!
        set_papertrail
        @owner = get_owner
      end

      route_param :id, type: Integer, requirements: { id: /[0-9]+/ } do
        desc 'Get a nic by id', success: Nic::Entity
        get do
          can_read!
          n = Nic.owned_by(@owner).find_by_id params[:id]
          error!('Not found', 404) unless n

          n
        end

        desc 'Update a single nic',
          params: Nic::Entity.documentation,
          success: Nic::Entity
        put do
          can_write!
          n = Nic.owned_by(@owner).find_by_fqdn params[:id]
          error!('Not found', 404) unless n

          params.delete("id")

          n.update_attributes(params)

          present n
        end

        desc 'Delete a single nic'
        delete do
          can_write!
          n = Nic.owned_by(@owner).find_by_fqdn params[:id]
          error!('Not found', 404) unless n

          n.destroy
          body false
        end
      end

      desc 'Return a list of nics, possibly filtered', is_array: true,
        success: Nic::Entity
      get do
        can_read!

        if params['machine']
          if Machine.owned_by(@owner).find_by_fqdn(params['machine'])
            params[:machine_id] = Machine.owned_by(@owner).find_by_fqdn(params['machine']).id
          else
            return []
          end
        end
        params.delete 'machine'

        # we cant use the following arel magick together with Nic.owned_by, so results are manually filtered after this.
        query = Nic.all
        params.delete('idb_api_token')
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(Nic.where(Nic.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!('Bad Request', 400)
        end

        nics = Array.new()
        query.each do |n|
          if n.machine and n.machine.owner == @owner
            nics << n
          end
        end

        present nics
      end

      desc 'Create a new nic', 
        params: Nic::Entity.documentation,
        success: Nic::Entity
      post do
        can_write!

        n = Nic.create!(params)
        present n
      end
    end
  end
end
