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

      # desc 'Create a new switch'
      # post do
      #   can_write!
      #   p = params.reject { |k| !Inventory.attribute_method?(k) }
      #   i = Inventory.create(p)
      #   i
      # end

      # desc "Get a inventory by inventory number"
      # get ':number', requirements: {number: /[a-zA-Z0-9.]+/ } do
      #   i = Inventory.find_by_inventory_number params[:number]
      #   error!("Not found", 404) unless i

      #   i
      # end

      # desc "Update a single inventory"
      # put ':number', requirements: {number: /[a-zA-Z0-9.]+/ } do
      #   i = Inventory.find_by_inventory_number params[:number]
      #   error!("Not found", 404) unless i

      #   p = params.reject { |k| !Inventory.attribute_method?(k) }

      #   i.update_attributes(p)

      #   i
      # end
    end
  end
end