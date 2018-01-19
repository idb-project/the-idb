module V3
  class Switches < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json

    resource :switches do
      before do
        api_enabled!
        authenticate!
        set_papertrail
        @owner = get_owner
        @owners = get_owners
      end

      route_param :rfqdn, type: String, requirements: { rfqdn: /.+/ } do
        resource :ports do
          route_param :number, type: Integer, requirements: { number: /[0-9]+/ } do
            desc 'Get a switch port',
              success: SwitchPort::Entity
            get do
              puts "GET /switches/fqdn/ports/number"
              can_read!
              s = Switch.owned_by(@owners).find_by_fqdn params[:rfqdn]
              error!('Not found', 404) unless s

              p = SwitchPort.find_by number: params[:number], switch_id: s.id
              error!('Not found', 404) unless p
              present p
            end

            desc 'Update a switch port',
              params: SwitchPort::Entity.documentation,
              success: SwitchPort::Entity
            put do
              can_write!
              s = Switch.owned_by(@owner).find_by_fqdn params[:rfqdn]
              error!('Not found 1', 404) unless s

              m = Machine.owned_by(@owner).find_by_fqdn params[:machine]
              error!('Machine not found', 404) unless m

              n = Nic.find_by(name: params[:nic], machine: m.id)
              error!('Nic not found', 404) unless n

              port = SwitchPort.find_by number: params[:number], switch_id: s.id
              error!('Not found', 404) unless port

              p = {'switch_id' => s.id, 'nic_id' => n.id, 'number' => params[:number]}
              port.update_attributes!(p)

              present port
              status 201
            end

            desc 'Delete a switch port'
            delete do
              can_write!
              port = SwitchPort.find_by_id params[:number]
              error!('Not found', 404) unless port

              port.destroy
            end
          end

          desc 'Return a list of switch ports', is_array: true, success: SwitchPort::Entity
          get do
            can_read!
            s = Switch.owned_by(@owners).find_by_fqdn params[:rfqdn]
            error!('Not found', 404) unless s

            present SwitchPort.where(switch_id: s.id)
          end

          desc 'Add a new switch port',
            params: SwitchPort::Entity.documentation,
            success: SwitchPort::Entity
          post do
            can_write!
            s = Switch.owned_by(@owner).find_by_fqdn params[:rfqdn]
            error!('Switch not found', 404) unless s

            m = Machine.owned_by(@owner).find_by_fqdn params[:machine]
            error!('Machine not found', 404) unless m

            n = Nic.find_by(name: params[:nic], machine: m.id)
            error!('Nic not found', 404) unless n

            p = {'switch_id' => s.id, 'nic_id' => n.id, 'number' => params[:number]}

            port = SwitchPort.create(p)
            present port
          end
        end

        desc 'Get a switch by fqdn',
          success: Switch::Entity
        get do
          puts "GET /switches/fqdn"
          can_read!
          s = Switch.owned_by(@owners).find_by_fqdn params[:rfqdn]
          error!('Not found', 404) unless s

          set_token item_update_token(s)

          present s
        end

        desc 'Update a switch',
          success: Switch::Entity
        put do
          can_write!
          s = Switch.owned_by(@owner).find_by_fqdn params[:rfqdn]
          error!('Not found', 404) unless s
          
          p = declared(params).to_h
          s.update_attributes(p)
          present s
        end

        desc 'Delete a switch'
        delete do
          can_write!
          s = Switch.owned_by(@owner).find_by_fqdn params[:rfqdn]
          error!('Not found', 404) unless s
          s.destroy
        end
      end

      desc 'Return a list of switches, possibly filtered', is_array: true, success: Switch::Entity
      get do
        can_read!

        query = Switch.owned_by(@owners).all
        params.delete('idb_api_token')
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(Switch.where(Switch.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!('Bad Request', 400)
        end

        present query
      end

      desc 'Create a new switch',
        params: Switch::Entity.documentation,
        success: Switch::Entity
      post do
        can_write!
        if Switch.owned_by(@owner).find_by_fqdn params['fqdn']
          error!('Entry with this FQDN already exists.', 409)
        end

        m = Switch.new(params)
        m.owner = @owner
        m.save!

        present m
      end
    end
  end
end
