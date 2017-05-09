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

      route_param :fqdn, requirements: {fqdn: /[a-zA-Z0-9.-]+/ } do

        resource :attachments do

          route_param :fingerprint, requirements: {fingerprint: /[a-f0-9]+/} do
            desc "Get an attachment"
            get do
              can_read!
              a = Attachment.find_by_attachment_fingerprint params[:fingerprint]
              error!("Not Found", 404) unless a

              a
            end

            desc "Delete an attachment"
            delete do
              can_write!
              a = Attachment.find_by_attachment_fingerprint params[:fingerprint]
              error!("Not Found", 404) unless a

              a.destroy!
            end
          end

          desc "Get all attachments"
          get do
            can_read!
            m = Machine.find_by_fqdn params[:fqdn]
            error!("Not Found", 404) unless m

            m.attachments
          end

          desc "Create an attachment"
          post do
            can_write!
            m = Machine.find_by_fqdn params[:fqdn]
            error!("Not Found", 404) unless m

            x = {
            filename: params[:data][:filename],
            size: params[:data][:tempfile].size,
            tempfile: params[:data][:tempfile]
            }
            
            attachment = ActionDispatch::Http::UploadedFile.new(x)

            m.attachments.create(attachment: attachment)
          end
        end

        resource :aliases do
          route_param :alias, requirements: {alias: /[a-zA-Z0-9.-]+/ } do
            desc "Get a alias"
            get do
              can_read!
              a = MachineAlias.find_by_name params[:alias]
              error!("Not Found", 404) unless a
              a
            end

            desc "Update an alias"
            put do
              can_write!
              a = MachineAlias.find_by_name params[:alias]
              error!("Not Found", 404) unless a
              
              p = params.reject { |k| !MachineAlias.attribute_method?(k) }
              
              a.update_attributes(p)
              a
            end

            desc "Delete an alias"
            delete do
              can_write!
              a = MachineAlias.find_by_name params[:alias]
              error!("Not Found", 404) unless a
              a.destroy
            end
          end

          desc "Get all aliases"
          get do
            can_read!
            m = Machine.find_by_fqdn params[:fqdn]
            error!("Not Found", 404) unless m

            m.aliases
          end

          desc "Create an alias"
          post do
            can_write!
            m = Machine.find_by_fqdn params[:fqdn]
            error!("Not Found", 404) unless m

            p = params.reject { |k| !MachineAlias.attribute_method?(k) }
            p = p.merge({"machine_id": m.id})

            a = MachineAlias.create(p)
            a
          end
        end

        resource :nics do
          route_param :name, requirements: {name: /[a-zA-Z0-9.-]+/ } do
            desc "Get a nic"
            get do
              can_read!
              m = Machine.find_by_fqdn params[:fqdn]
              error!("Not Found", 404) unless m

              n = Nic.where(machine_id: m.id, name: params[:name])
              error!("Not Found", 404) unless n
              n
            end

            desc "Update a nic"
            put do
              can_write!
              m = Machine.find_by_fqdn params[:fqdn]
              error!("Not Found", 404) unless m

              n = Nic.where(machine_id: m.id, name: params[:name])
              error!("Not Found", 404) unless n
              
              p = params.reject { |k| !Nic.attribute_method?(k) }
              
              n.update_attributes(p)
              n
            end

            desc "Delete a nic"
            delete do
              can_write!
              m = Machine.find_by_fqdn params[:fqdn]
              error!("Not Found", 404) unless m

              n = Nic.find_by machine_id: m.id, name: params[:name]
              error!("Not Found", 404) unless n

              n.destroy
            end
          end

          desc "Get all nics"
          get do
            can_read!
            m = Machine.find_by_fqdn params[:fqdn]
            error!("Not Found", 404) unless m

            m.nics
          end

          desc "Create a nic"
          post do
            can_write!
            m = Machine.find_by_fqdn params[:fqdn]
            error!("Not Found", 404) unless m

            p = params.reject { |k| !Nic.attribute_method?(k) }
            p = p.merge({machine_id: m.id})

            n = Nic.create(p)
            n
          end
        end

        desc "Get a machine by fqdn"
        get serializer: MachineSerializer do
          can_read!
          m = Machine.find_by_fqdn params[:fqdn]
          error!("Not Found", 404) unless m

          m
        end

        desc "Update a single machine"
        put serializer: MachineSerializer  do
          can_write!
          m = Machine.find_by_fqdn params[:fqdn]
          error!("Not Found", 404) unless m

          p = params.reject { |k| !Machine.attribute_method?(k) }
          if p["nics"]
            error!("Update nics via nics subroute")
          end

          if p["aliases"]
            error!("Update aliases via aliases subroute")
          end

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

          m.save

          m
        end

        desc "Delete a machine"
        delete do
          can_write!
          m = Machine.find_by_fqdn params[:fqdn]
          error!("Not Found", 404) unless m
          m.destroy
        end
      end

      desc "Return a list of machines, possibly filtered"
      get serializer: MachineSerializer do # use MachineSerializer for VirtualMachines and Switches
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
      post serializer: MachineSerializer do
        can_write!
        p = params.reject { |k| !Machine.attribute_method?(k) }
        m = Machine.create(p)
        m
      end
    end
  end
end