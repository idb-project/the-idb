module V3
  class Machines < Grape::API
    helpers MachineHelpers
    helpers V3::Helpers

    version 'v3'
    format :json

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
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!("Bad Request", 400)
        end

        present query, with: Machine::Entity
      end

      desc 'Create a new machine'
      post do
        can_write!
        p = params.reject { |k| !Machine.attribute_method?(k) }
        m = Machine.create(p)
        present m, with: Machine::Entity
      end

      desc "Get a machine by fqdn"
      get ':fqdn', requirements: {fqdn: /[a-zA-Z0-9.]+/ } do
        m = Machine.find_by_fqdn params[:fqdn]
        error!("Not found", 404) unless m
        present m, with: Machine::Entity
      end

      desc "Update a single machine"
      put ':fqdn', requirements: {fqdn: /[a-zA-Z0-9.]+/ } do
        m = Machine.find_by_fqdn params[:fqdn]
        error!("Not found", 404) unless m

        p = params.reject { |k| !Machine.attribute_method?(k) }

        p_nics = Hash.new
        p_nics[:nics] = p.delete("nics")

        p_aliases = Hash.new
        p_aliases[:aliases] = p.delete("aliases")

        p_power_feed_a = Hash.new
        p_power_feed_a[:power_feed_a] = p.delete("power_feed_a")

        p_power_feed_b = Hash.new
        p_power_feed_b[:power_feed_b] = p.delete("power_feed_b")

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
        m.update_details_by_api(p_nics, EditableMachineForm.new(m))
        m.update_details_by_api(p_aliases, EditableMachineForm.new(m))
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