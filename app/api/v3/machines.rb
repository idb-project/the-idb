module V3
  class Machines < Grape::API
    helpers MachineHelpers
    helpers V3::Helpers

    version 'v3'
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    resource :machines do
      before do
        api_enabled!
        authenticate!
        set_papertrail
      end

      desc "Return a list of machines, possibly filtered"
      get do
        can_read!

        # first get all machines
        query = Machine.all

        # strip possible idb_api_token parameter, this isn't a key of machines
        params.delete("idb_api_token")

        # then add a where condition for each parameter of the request
        params.each do |key, value|
          # arel_table uses symbols to get a symbol from the key string
          keysym = key.to_sym
          # merge AND connects the next "where" condition, which is build using arel_table of Machine
          # (http://www.rubydoc.info/github/rails/arel/Arel/Table)
          query = query.merge(Machine.where(Machine.arel_table[keysym].eq(value)))
        end

        # test if there were any keys which are no column names.
        # otherwise the exception would be thrown when rendering.
        # return 400 for such a request.
        begin
          unless query.any?
            error!("Not Found", 404)
          end
        rescue ActiveRecord::StatementInvalid
          error!("Bad Request", 400)
        end

        query
      end

      desc 'Create a new machine'
      post do
        can_write!
        p = params.reject { |k| !Machine.attribute_method?(k) }
        m = Machine.create(p)
        m
      end

      desc "Get a machine by fqdn"
      get ':fqdn', requirements: {fqdn: /[a-zA-Z0-9.-]+/ } do
        m = Machine.find_by_fqdn params[:fqdn]
        error!("Not Found", 404) unless m

        m
      end

      desc "Update a single machine"
      put ':fqdn', requirements: {fqdn: /[a-zA-Z0-9.-]+/ } do
        can_write!
        m = Machine.find_by_fqdn params[:fqdn]
        error!("Not Found", 404) unless m

        p = params.reject { |k| !Machine.attribute_method?(k) }
        p.delete("aliases")

        m.update_attributes(p)

        is_backed_up = false
        if (
          (p["backup_brand"] && p["backup_brand"].to_i > 0) ||
          !p["backup_last_full_run"].blank? ||
          !p["backup_last_inc_run"].blank? ||
          !p["backup_last_diff_run"].blank? ||
          !p["backup_last_full_size"].blank? ||
          !p["backup_last_inc_size"].blank? ||
          !p["backup_last_diff_size"].blank?
          )
          is_backed_up = true
        end

        m.backup_type = 1 if is_backed_up

        m.power_feed_a = params[:power_feed_a_id] ? Location.find_by_id(params[:power_feed_a_id]) : m.power_feed_a
        m.power_feed_b = params[:power_feed_b_id] ? Location.find_by_id(params[:power_feed_b_id]) : m.power_feed_b

        aliases = MachineAlias.where(name: params[:aliases])

        m.aliases = aliases
        m.save

        m
      end
    end
  end
end



        # desc 'Update a machine'
        # put do
        #   can_write!

        #   p = params.reject { |k| !Machine.attribute_method?(k) }

        #   if p["fqdn"]
        #     begin
        #       m = process_machine_update(p)
        #       return {} unless m
        #       m
        #     rescue ActiveRecord::RecordInvalid => e
        #       Raven.capture_exception(e)
        #       status 409
        #       return {}
        #     rescue ActiveRecord::RecordNotUnique => e
        #       Raven.capture_exception(e)
        #       status 409
        #       return {}
        #     end
        #   elsif p["machines"]
        #     machine_array = Array.new
        #     p["machines"].each do |machine_params|
        #       machine_params["create_machine"] = "true" if (p["create_machine"] == true || p["create_machine"] == "true")
        #       begin
        #         m = process_machine_update(machine_params)
        #         machine_array << m if m
        #       rescue ActiveRecord::RecordInvalid => e
        #         Raven.capture_exception(e)
        #         status 409
        #         return {}
        #       rescue ActiveRecord::RecordNotUnique => e
        #         Raven.capture_exception(e)
        #         status 409
        #         return {}
        #       end
        #     end
        #     machine_array
        #   else
        #     status 400
        #     {}
        #   end
        # end