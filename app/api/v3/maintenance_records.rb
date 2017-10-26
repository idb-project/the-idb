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
        end

        route_param :rfqdn, type: String, requirements: { rfqdn: /.*/ } do
            route_param :rcreated_at, type: String, requirements: { rcreated_at: /[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z/ } do
                resource :attachments do
                    route_param :fingerprint, type: String, requirements: { fingerprint: /[a-f0-9]+/ } do
                      desc 'Get an attachment' do
                        success Attachment::Entity
                      end
                      get do
                        can_read!
                        a = Attachment.owned_by(@owner).find_by_attachment_fingerprint params[:fingerprint]
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
                      m = Machine.owned_by(@owner).find_by_fqdn(params[:rfqdn])
                      if not m
                          a = MachineAlias.find_by_name(params[:rfqdn])
                          if not a
                              error!("Not found1", 404)
                          end
                          m = Machine.owned_by(@owner).find_by_id(a.machine_id)
                          if not m
                              error!("Not found2", 404)
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
                              error!("Not found1", 404)
                          end
                          m = Machine.owned_by(@owner).find_by_id(a.machine_id)
                          if not m
                              error!("Not found2", 404)
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
                    m = Machine.owned_by(@owner).find_by_fqdn(params[:rfqdn])
                    if not m
                        a = MachineAlias.find_by_name(params[:rfqdn])
                        if not a
                            error!("Not found1", 404)
                        end
                        m = Machine.owned_by(@owner).find_by_id(a.machine_id)
                        if not m
                            error!("Not found2", 404)
                        end
                    end
                    
                    r = MaintenanceRecord.find_by_machine_id_and_created_at(m.id, params[:rcreated_at])
                    present r
                end
            end


            desc "Get maintenance records by machine",
                is_array: true,
                success: MaintenanceRecord::Entity
            get do
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
  
          present query
        end
  
        desc 'Create a new maintenance record',
          params: MaintenanceRecord::Entity.documentation,
          success: MaintenanceRecord::Entity
        post do
          can_write!
          
          params["machine_id"] = Machine.find_by_fqdn(params["machine"])
          params.delete("machine")
          params["user_id"] = User.find_by_login(params["user"])
          params.delete("user")
            
          m = MaintenanceRecord.new(params)
          m.owner = @owner
          m.save!
          present m
        end
      end
    end
  end
  