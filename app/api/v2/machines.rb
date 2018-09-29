module V2
  class Machines < Grape::API
    helpers MachineHelpers
    helpers V2::Helpers

    version 'v2'
    format :json

    resource :machines do
      desc "Return a list of all machines"
      get do
        unless IDB.config.modules.api.v2_enabled
          status 501
          return {}
        end
        authenticate!
        can_read!

        p = params.to_hash

        unless p["fqdn"]
          Machine.includes(:aliases, :nics).all.as_json(include: [ :aliases, :nics ])
        else
          m = Machine.includes(:aliases, :nics).find_by_fqdn(p["fqdn"]).as_json(include: [:aliases, :nics])
          unless m
            status 404
            {}
          else
            m
          end
        end
      end
    end

    resource :machines do
      desc 'Create or update a machine'
      put do
        unless IDB.config.modules.api.v2_enabled
          status 501
          return {}
        end
        authenticate!
        can_write!
        
        p = params.to_hash

        if p["fqdn"]
          begin
            m = process_machine_update(p)
            return {} unless m
            m = Machine.includes(:aliases, :nics).find_by_fqdn(p["fqdn"]).as_json(include: [:aliases, :nics])
            m
          rescue ActiveRecord::RecordInvalid => e
            status 409
            return {}
          rescue ActiveRecord::RecordNotUnique => e
            status 409
            return {}
          end
        elsif p["machines"]
          machine_array = Array.new
          p["machines"].each do |machine_params|
            machine_params["create_machine"] = "true" if (p["create_machine"] == true || p["create_machine"] == "true")
            begin
              m = process_machine_update(machine_params)
              if m
                m = Machine.includes(:aliases, :nics).find_by_fqdn(m["fqdn"]).as_json(include: [:aliases, :nics])
                machine_array << m
              end
            rescue ActiveRecord::RecordInvalid => e
              status 409
              return {}
            rescue ActiveRecord::RecordNotUnique => e
              status 409
              return {}
            end
          end
          machine_array
        else
          status 400
          {}
        end
      end
    end
  end
end
