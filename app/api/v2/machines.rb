module V2
  class Machines < Grape::API
    helpers MachineHelpers
    helpers do
      def get_token
        if params[:idb_api_token]
          return params[:idb_api_token]
        elsif request.headers["X-Idb-Api-Token"]
          return request.headers["X-Idb-Api-Token"]
        else
          error!("Unauthorized.", 401)
        end
      end

      def authenticate!
        token = params[:idb_api_token] ? params[:idb_api_token] : request.headers["X-Idb-Api-Token"]
        if ApiToken.where("token = ?", token).empty?
          error!("Unauthorized.", 401)
        end
      end

      def can_read!
        token = params[:idb_api_token] ? params[:idb_api_token] : request.headers["X-Idb-Api-Token"]
        unless ApiToken.where("token = ?", token).first.read
          error!("Unauthorized.", 401)
        end
      end

      def can_write!
        token = params[:idb_api_token] ? params[:idb_api_token] : request.headers["X-Idb-Api-Token"]
        unless ApiToken.where("token = ?", token).first.write
          error!("Unauthorized.", 401)
        end
      end
    end

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
          Machine.all
        else
          m = Machine.find_by_fqdn(p["fqdn"])
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
            m
          rescue ActiveRecord::RecordInvalid => e
            Raven.capture_exception(e)
            status 409
            return {}
          rescue ActiveRecord::RecordNotUnique => e
            Raven.capture_exception(e)
            status 409
            return {}
          end
        elsif p["machines"]
          machine_array = Array.new
          p["machines"].each do |machine_params|
            machine_params["create_machine"] = "true" if (p["create_machine"] == true || p["create_machine"] == "true")
            begin
              m = process_machine_update(machine_params)
              machine_array << m if m
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
          machine_array
        else
          status 400
          {}
        end
      end
    end
  end
end
