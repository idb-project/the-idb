module V3
    class MaintenanceRecords < Grape::API
      helpers V3::Helpers
  
      version 'v3'
      format :json
  
      resource :maintenance_records do
        before do
          api_enabled!
          authenticate!
          set_papertrail
          @owner = get_owner
          @owners = get_owners
        end

        route_param :rfqdn, type: String, requirements: { rfqdn: /.+/ } do
            route_param :rcreated_at, type: String, requirements: { rcreated_at: /.+/ } do
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
                    end
            
                    desc 'Get all attachments',
                        is_array: true,
                        success: Attachment::Entity
                    get do
                        can_read!
                        m = Machine.owned_by(@owners).find_by_fqdn(params[:rfqdn])
                        if not m
                            a = MachineAlias.find_by_name(params[:rfqdn])
                            if not a
                                error!("Not found", 404)
                            end
                            m = Machine.owned_by(@owners).find_by_id(a.machine_id)
                            if not m
                                error!("Not found", 404)
                            end
                        end
                        
                        r = MaintenanceRecord.find_by_machine_id_and_created_at(m.id, params[:rcreated_at])
                        error!('Not Found', 404) unless r
            
                        present r.attachments
                    end
            
                    desc 'Create an attachment',
                        success: Attachment::Entity
                    params do
                        requires :data, type: Rack::Multipart::UploadedFile
                    end
                    post do
                        can_write!
                        m = Machine.owned_by(@owner).find_by_fqdn(params[:rfqdn])
                        if not m
                            a = MachineAlias.find_by_name(params[:rfqdn])
                            if not a
                                error!("Not found", 404)
                            end
                            m = Machine.owned_by(@owner).find_by_id(a.machine_id)
                            if not m
                                error!("Not found", 404)
                            end
                        end
                        
                        r = MaintenanceRecord.find_by_machine_id_and_created_at(m.id, params[:rcreated_at])
                        error!('Not Found', 404) unless r
                                
                        x = {
                        filename: params[:data][:filename],
                        size: params[:data][:tempfile].size,
                        tempfile: params[:data][:tempfile]
                        }
                        
                        attachment = ActionDispatch::Http::UploadedFile.new(x)
            
                        present r.attachments.create(attachment: attachment, owner: m.owner)
                    end
                end

                desc "Get a maintenance record by machine and creation time",
                    success: MaintenanceRecord::Entity
                get do
                    can_read!

                    m = Machine.owned_by(@owners).find_by_fqdn(params[:rfqdn])
                    if not m
                        a = MachineAlias.find_by_name(params[:rfqdn])
                        if not a
                            error!("Not found", 404)
                        end
                        m = Machine.owned_by(@owners).find_by_id(a.machine_id)
                        if not m
                            error!("Not found", 404)
                        end
                    end
                    
                    r = MaintenanceRecord.find_by_machine_id_and_created_at(m.id, params[:rcreated_at])

                    set_token item_update_token(m)

                    present r
                end
            end

            desc "Get maintenance records by machine",
                is_array: true,
                success: MaintenanceRecord::Entity
            get do
                can_read!
                m = Machine.owned_by(@owners).find_by_fqdn(params[:rfqdn])
                if not m
                    a = MachineAlias.find_by_name(params[:rfqdn])
                    if not a
                        error!("Not found", 404)
                    end
                    m = Machine.owned_by(@owners).find_by_id(a.machine_id)
                    if not m
                        error!("Not found", 404)
                    end
                end

                r = MaintenanceRecord.where(machine_id: m.id)
                present r
            end
        end
  
        desc 'Return a list of maintenance records, possibly filtered',
          is_array: true,
          success: MaintenanceRecord::Entity
        get do
          can_read!
          if params['machine']
            if Machine.find_by_fqdn(params['machine'])
              params[:machine_id] = Machine.find_by_fqdn(params['machine']).id
            else
              return []
            end
          end
          params.delete 'machine'
  
          if params['user']
            if User.find_by_login(params['user'])
              params[:user_id] = User.find_by_login(params['user']).id
            else
              return []
            end
          end
          params.delete 'user'

          
          query = MaintenanceRecord.all
          params.delete('idb_api_token')
          params.each do |key, value|
            keysym = key.to_sym
            query = query.merge(MaintenanceRecord.where(MaintenanceRecord.arel_table[keysym].eq(value)))
          end
  
          begin
            query.any?
          rescue ActiveRecord::StatementInvalid
            error!('Bad Request', 400)
          end

          mrs = Array.new()
          query.each do |mr|
            if mr.machine and @owners.include? mr.machine.owner
              mrs << mr
            end
          end
  
          present mrs
        end
  
        desc 'Create a new maintenance record',
          params: MaintenanceRecord::Entity.documentation,
          success: MaintenanceRecord::Entity
        post do
          can_post_logs!
          machine = Machine.find_by_fqdn(params["machine"])
          m = Machine.owned_by(machine.owner).find_by_fqdn(params["machine"])
          params["machine_id"] = m.id
          params["fqdn"] = m.fqdn
          params.delete("machine")

          u = User.find_by_login(params["user"])
          params["user_id"] = u.id
          params.delete("user")
          params.delete("password")

          record = MaintenanceRecord.new(params)
          record.logfile.gsub!("[?2004h", "")
          record.logfile.gsub!("[?2004l", "")
          record.logfile.gsub!(/\e\r/i, "")
          record.logfile.gsub!(/\e/i, "")
          record.save!
          { :response_type => 'success', :response => "Record for machine #{m.fqdn} created" }.to_json
        end
      end
    end
  end
