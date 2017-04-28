module V3
  class Switches < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    resource :switches do
      before do
        api_enabled!
        authenticate!
        set_papertrail
      end

      desc "Return a list of switches, possibly filtered"
      get serializer: SwitchSerializer do
        can_read!

        query = Machine.switches
        params.delete("idb_api_token")
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(Machine.where(Machine.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!("Bad Request", 400)
        end

        query
      end

      # TODO: How to create switch ports?
      desc 'Create a new switch'
      post serializer: SwitchSerializer do
        can_write!
        unless params['device_type_id'] == 3
          error!("Bad Request: Not a switch.", 400)
        end

        p = params.reject { |k| !Machine.attribute_method?(k) }
        i = Machine.create(p)
        i
      end

      desc "Get a switch by name (fqdn)"
      get ':name', requirements: {name: /[a-zA-Z0-9.]+/ }, serializer: SwitchSerializer do
        m = Machine.find_by_fqdn params[:name]
        error!("Not found", 404) unless m

        m
      end

      # TODO: How to create switch ports?
      desc "Update a single switch"
      put ':name', requirements: {name: /[a-zA-Z0-9.]+/ }, serializer: SwitchSerializer do
        m = Machine.find_by_fqdn params[:name]
        error!("Not found", 404) unless m

        p = params.reject { |k| !Machine.attribute_method?(k) }

        m.update_attributes(p)

        m
      end
    end
  end
end