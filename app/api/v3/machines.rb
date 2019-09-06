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
        @owners = get_owners
        @owner = get_owner
      end

      route_param :rfqdn, type: String, requirements: { rfqdn: /.+/ } do
        resource :attachments do
          route_param :fingerprint, type: String, requirements: { fingerprint: /[a-f0-9]+/ } do
            desc 'Get an attachment' do
              success Attachment::Entity
            end
            get do
              can_read!
              a = Attachment.owned_by(@owners).find_by_attachment_fingerprint params[:fingerprint]
              error!('Not Found', 404) unless a

              present a
            end

            desc 'Delete an attachment'
            delete do
              can_write!
              a = Attachment.owned_by(@owner).find_by_attachment_fingerprint params[:fingerprint]
              error!('Not Found', 404) unless a

              a.destroy!
              body false
            end
          end

          desc 'Get all attachments',
            is_array: true,
            success: Attachment::Entity
          get do
            can_read!
            m = Machine.owned_by(@owners).find_by_fqdn params[:rfqdn]
            error!('Not Found', 404) unless m

            present m.attachments
          end

          desc 'Create an attachment',
            success: Attachment::Entity
          params do
            requires :data, type: Rack::Multipart::UploadedFile
          end
          post do
            can_write!
            m = Machine.owned_by(@owner).find_by_fqdn params[:rfqdn]
            error!('Not Found', 404) unless m

            x = {
              filename: params[:data][:filename],
              size: params[:data][:tempfile].size,
              tempfile: params[:data][:tempfile]
            }

            attachment = ActionDispatch::Http::UploadedFile.new(x)

            present m.attachments.create(attachment: attachment, owner: m.owner)
          end
        end

        resource :aliases do
          route_param :alias, type: String, requirements: { alias: /.+/ } do
            desc 'Get a alias',
              success: MachineAlias::Entity
            get do
              can_read!
              a = MachineAlias.find_by_name params[:alias]
              error!('Not Found', 404) unless a
              present a
            end

            desc 'Update an alias',
              params: MachineAlias::Entity.documentation,
              success: MachineAlias::Entity
            put do
              can_write!
              a = MachineAlias.find_by_name params[:alias]
              error!('Not Found', 404) unless a

              # remove route parameters for updating
              params.delete('rfqdn')
              params.delete('alias')

              a.update_attributes(params)
              present a
            end

            desc 'Delete an alias'
            delete do
              can_write!
              a = MachineAlias.find_by_name params[:alias]
              error!('Not Found', 404) unless a
              a.destroy
              body false
            end
          end

          desc 'Get all aliases',
            is_array: true,
            success: MachineAlias::Entity
          get do
            can_read!
            m = Machine.owned_by(@owners).find_by_fqdn params[:rfqdn]
            error!('Not Found', 404) unless m

            present m.aliases
          end

          desc 'Create an alias',
            params: MachineAlias::Entity.documentation,
            success: MachineAlias::Entity
          post do
            can_write!
            m = Machine.owned_by(@owner).find_by_fqdn params[:rfqdn]
            error!('Not Found', 404) unless m

            params["machine"] = m
            params.delete("rfqdn")

            a = MachineAlias.create(params)
            present a
          end
        end

        resource :nics do
          route_param :rnic, type: String, requirements: { name: /[a-zA-Z0-9.-]+/ } do
            desc 'Get a nic',
              success: Nic::Entity
            get do
              can_read!
              m = Machine.owned_by(@owners).find_by_fqdn params[:rfqdn]
              error!('Not Found', 404) unless m

              n = Nic.where(machine_id: m.id, name: params[:rnic])
              error!('Not Found', 404) unless n
              present n
            end

            desc 'Update a nic',
              params: Nic::Entity.documentation,
              success: Nic::Entity
            put do
              can_write!
              m = Machine.owned_by(@owner).find_by_fqdn params[:rfqdn]
              error!('Not Found', 404) unless m

              n = Nic.where(machine_id: m.id, name: params[:rnic])
              error!('Not Found', 404) unless n

              params.delete("rnic")
              params.delete("rfqdn")

              n.update_attributes(params)
              present n
            end

            desc 'Delete a nic'
            delete do
              can_write!
              m = Machine.owned_by(@owner).find_by_fqdn params[:rfqdn]
              error!('Not Found', 404) unless m

              n = Nic.find_by machine_id: m.id, name: params[:rnic]
              error!('Not Found', 404) unless n

              n.destroy
              body false
            end
          end

          desc 'Get all nics',
            is_array: true,
            success: Nic::Entity
          get do
            can_read!
            m = Machine.owned_by(@owners).find_by_fqdn params[:rfqdn]
            error!('Not Found', 404) unless m

            present m.nics
          end

          desc 'Create a nic',
            params: Nic::Entity.documentation,
            success: Nic::Entity
          post do
            can_write!
            m = Machine.owned_by(@owner).find_by_fqdn params[:rfqdn]
            error!('Not Found', 404) unless m

            nic_p = params.select { |k| Nic.attribute_method?(k) }
            ip_address_p = params['ip_address'].select { |k| IpAddress.attribute_method?(k) }

            i = IpAddress.new(ip_address_p)

            nic_p.delete('ip_address')
            nic_p['ip_address'] = i
            nic_p['machine'] = m
            n = Nic.create!(nic_p)

            present n
          end
        end

        desc 'Get a machine by fqdn',
          success: Machine::Entity
        get do
          can_read!
          m = Machine.owned_by(@owners).find_by_fqdn params[:rfqdn]
          error!('Not Found', 404) unless m

          set_token item_update_token(m)

          present m
        end

        desc 'Update a single machine',
          params: Machine::Entity.documentation,
          success: Machine::Entity
        put do
          tok = can_write!
          m = Machine.owned_by(@owner).find_by_fqdn params[:rfqdn]

          error!('Not Found', 404) unless m
                    
          # move route parameter to params
          if not params['fqdn']
            params['fqdn'] = params['rfqdn']
          end
          params.delete('rfqdn')

          if not Machine::FQDN_REGEX.match(params['fqdn'])
            error!('Invalid Machine', 409)
          end

          if m.raw_data_api
            params['raw_data_api'] = JSON.parse(m.raw_data_api).merge({tok.name => params}).to_json
          else
            params['raw_data_api'] = {tok.name => params}.to_json
          end

          begin
            m.update_attributes(params)
          rescue ActiveModel::UnknownAttributeError
            error!('Invalid Machine', 409)
          end

          m.power_feed_a = params[:power_feed_a_id] ? Location.find_by_id(params[:power_feed_a_id]) : m.power_feed_a
          m.power_feed_b = params[:power_feed_b_id] ? Location.find_by_id(params[:power_feed_b_id]) : m.power_feed_b

          m.save

          present m
        end

        desc 'Delete a machine'
        delete do
          can_write!
          m = Machine.owned_by(@owner).find_by_fqdn params[:rfqdn]
          error!('Not Found', 404) unless m
          m.destroy
          body false
        end
      end

      desc 'Return a list of machines, possibly filtered',
        is_array: true,
        success: Machine::Entity
      params do
        optional :fqdn, type: String, documentation: { type: "String", desc: "FQDN" }
        optional :os, type: String, documentation: { type: "String", desc: "Operating system" }
        optional :os_release, type: String, documentation: { type: "String", desc: "Operating system release" }
        optional :arch, type: String, documentation: { type: "String", desc: "Architecture" }
        optional :ram, type: Integer, documentation: { type: "Integer", desc: "Amount of RAM in MB" }
        optional :cores, documentation: { type: "Integer", desc: "Number of CPU cores" }
        optional :vmhost, type: String, documentation: { type: "String", desc: "FQDN of virtual machine host if this is a virtual machine" }
        optional :serviced_at, type: String, documentation: { type: "String", desc: "Service date RFC3999 formatted" }
        optional :description, type: String, documentation: { type: "String", desc: "Description" }
        optional :deleted_at, type: String, documentation: { type: "String", desc: "Deletion date RFC3999 formatted" }
        optional :created_at, type: String, documentation: { type: "String", desc: "Creation date RFC3999 formatted" }
        optional :updated_at, type: String, documentation: { type: "String", desc: "Update date RFC3999 formatted" }
        optional :uptime, type: Integer, documentation: { type: "Integer", desc: "Uptime in seconds" }
        optional :serialnumber, type: String, documentation: { type: "String", desc: "Serial number" }
        optional :backup_type, type: Integer, documentation: { type: "Integer", desc: "Backup type" }
        optional :auto_update, type: Boolean, documentation: { type: "Boolean", desc: "true if the machine is updated automatically" }
        optional :switch_url, type: String, documentation: { type: "String" }
        optional :mrtg_url, type: String, documentation: { type: "String" }
        optional :config_instructions, type: String, documentation: { type: "String", desc: "Configuration instructions" }
        optional :sw_characteristics , type: String, documentation: { type: "String", desc: "Software characteristics" }
        optional :business_purpose, type: String, documentation: { type: "String", desc: "Business purpose" }
        optional :business_criticality, type: String, documentation: { type: "String", desc: "Business Criticality" }
        optional :business_notification, type: String, documentation: { type: "String", desc: "Business Notification" }
        optional :unattended_upgrades, type: Boolean, documentation: { type: "Boolean" }
        optional :unattended_upgrades_blacklisted_packages, type: String, documentation: { type: "String" }
        optional :unattended_upgrades_reboot, type: Boolean, documentation: { type: "Boolean" }
        optional :unattended_upgrades_time, type: String, documentation: { type: "String" }
        optional :unattended_upgrades_repos, type: String, documentation: { type: "String" }
        optional :pending_updates, type: Integer, documentation: { type: "Integer" }
        optional :pending_security_updates, type: Integer, documentation: { type: "Integer" }
        optional :pending_updates_sum, type: Integer, documentation: { type: "Integer" }
        optional :diskspace, type: Integer, documentation: { type: "Integer", desc: "Disc space in bytes" }
        optional :pending_updates_package_names, type: String, documentation: { type: "String" }
        optional :severity_class, type: String, documentation: { type: "String" }
        optional :ucs_role, type: String, documentation: { type: "String" }
        optional :raw_data_api, type: String, documentation: { type: "String" }
        optional :raw_data_puppetdb, type: String, documentation: { type: "String" }
        optional :needs_reboot, type: Boolean, documentation: { type: "Boolean" }
        optional :software, type: Array, documentation: {is_array: true, type: "String", desc: "Known installed doftware packages" }
        optional :power_feed_a, type: Integer, documentation: { type: "Integer", desc: "Location id of power feed a" }
        optional :power_feed_b, type: Integer, documentation: { type: "Integer", desc: "Location id of power feed b" }
      end
      get do
        can_read!

        # first get all machines
        query = Machine.owned_by(@owners).all

        # strip possible idb_api_token parameter, this isn't a key of machines
        params.delete('idb_api_token')

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
          error!('Not Found', 404) unless query.any?
        rescue ActiveRecord::StatementInvalid
          error!('Bad Request', 400)
        end

        present query
      end

      desc 'Create a new machine', 
        params: Machine::Entity.documentation,
        success: Machine::Entity
      post do
        tok = can_write!

        if not Machine::FQDN_REGEX.match(params['fqdn'])
          error!('Invalid Machine', 409)
        end

        params['raw_data_api'] = {tok.name => params}.to_json

        begin
          m = Machine.new(params)
          m.owner = @owner
          m.save!
        rescue ActiveRecord::RecordInvalid
          error!('Invalid Machine', 409)
        end
        present m
      end
    end
  end
end
