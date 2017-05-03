module V3
  class Locations < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    resource :locations do

      route_param :id do
        desc "Get location by id"
        get do
          l = Location.find_by_id params[:id]
          error!("Not Found", 404) unless l

          l
        end

        desc "Create a new child location"
        post do
        end

        desc "Update a location"
        put do
        end

        desc "Delete a location"
        delete do
        end
      end


      before do
        api_enabled!
        authenticate!
        set_papertrail
      end

      desc "Get the location roots"
      get do
        can_read!
        Location.roots.sort_by {|l| l.name}
      end
    end
  end
end



      # route_param :fqdn, requirements: {fqdn: /[a-zA-Z0-9.]+/ } do
      #   desc "Get a switch by fqdn"
      #   get do
      #     can_read!
      #     s = Switch.find_by_fqdn params[:fqdn]
      #     error!("Not found", 404) unless s

      #     s
      #   end

      #   desc "Update a switch"
      #   put do
      #     can_write!
      #     s = Switch.find_by_fqdn params[:fqdn]
      #     error!("Not found", 404) unless s
      #     p = params.reject { |k| !Switch.attribute_method?(k) }
      #     s.update_attributes(p)
      #     s
      #   end

      #   desc "Delete a switch"
      #   delete do
      #     can_write!
      #     s = Switch.find_by_fqdn params[:fqdn]
      #     error!("Not found", 404) unless s
      #     s.destroy
      #   end

      #   resource :ports do
      #     route_param :number, requirements: {number: /[0-9]+/ } do
      #       desc "Get a switch port"
      #       get do
      #         can_read!
      #         s = Switch.find_by_fqdn params[:fqdn]
      #         error!("Not found", 404) unless s              

      #         p = SwitchPort.find_by number: params[:number], switch_id: s.id
      #         error!("Not found", 404) unless p
      #         p
      #       end

      #       desc "Update a switch port"
      #       put do
      #         can_write!
      #         s = Switch.find_by_fqdn params[:fqdn]
      #         error!("Not found", 404) unless s              

      #         port = SwitchPort.find_by number: params[:number], switch_id: s.id
      #         error!("Not found", 404) unless port

      #         p = params.reject { |k| !SwitchPort.attribute_method?(k) }
      #         port.update_attributes(p)
      #         port
      #       end

      #       desc "Delete a switch port"
      #       delete do
      #         can_write!
      #         port = SwitchPort.find_by_id params[:number]
      #         error!("Not found", 404) unless port

      #         port.destroy
      #       end
      #     end

      #     desc "Return a list of switch ports"
      #     get do
      #       can_read!
      #       s = Switch.find_by_fqdn params[:fqdn]
      #       error!("Not found", 404) unless s

      #       SwitchPort.where(switch_id: s.id)
      #     end

      #     desc "Add a new switch port"
      #     post do
      #       can_write!
      #       s = Switch.find_by_fqdn params[:fqdn]
      #       error!("Not found", 404) unless s
            
      #       p = params.reject { |k| !SwitchPort.attribute_method?(k) }
      #       p = p.merge({switch_id: s.id})

      #       port = SwitchPort.create(p)
      #       port
      #     end
      #   end
      # end

      # desc "Return a list of switches, possibly filtered"
      # get do
      #   can_read!

      #   query = Switch.all
      #   params.delete("idb_api_token")
      #   params.each do |key, value|
      #     keysym = key.to_sym
      #     query = query.merge(Switch.where(Switch.arel_table[keysym].eq(value)))
      #   end

      #   begin
      #     query.any?
      #   rescue ActiveRecord::StatementInvalid
      #     error!("Bad Request", 400)
      #   end

      #   query
      # end