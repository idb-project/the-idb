module V3
  class Inventories < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json
    #    formatter :json, Grape::Formatter::ActiveModelSerializers

    resource :inventories do
      before do
        api_enabled!
        authenticate!
        set_papertrail
        @owner = get_owner
      end

      route_param :inventory_number, type: String do
        resource :attachments do
          route_param :fingerprint, type: String, requirements: { fingerprint: /[a-f0-9]+/ } do
            desc 'Get an attachment', detail: 'WAT?',
                                      success: Attachment::Entity
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

          desc 'Get all attachments', is_array: true,
                                      success: Attachment::Entity
          get do
            can_read!
            i = Inventory.owned_by(@owner).find_by_inventory_number params[:inventory_number]
            error!('Not Found', 404) unless i

            present i.attachments
          end

          desc 'Create an attachment', success: Attachment::Entity
          params do
            requires :data, type: Rack::Multipart::UploadedFile
          end
          post do
            can_write!
            i = Inventory.owned_by(@owner).find_by_inventory_number params[:inventory_number]
            error!('Not Found', 404) unless i

            x = {
              filename: params[:data][:filename],
              size: params[:data][:tempfile].size,
              tempfile: params[:data][:tempfile]
            }

            attachment = ActionDispatch::Http::UploadedFile.new(x)

            present i.attachments.create(attachment: attachment, owner: i.owner)
          end
        end

        desc 'Get a inventory by inventory number', success: Inventory::Entity
        get do
          can_read!
          i = Inventory.owned_by(@owner).find_by_inventory_number params[:inventory_number]
          error!('Not found', 404) unless i

          present i
        end

        desc 'Update a single inventory', success: Inventory::Entity
        params do
          requires :inventory_number, type: String, documentation: { type: "String", desc: "Inventory Number" }
          optional :name, type: String, documentation: { type: "String", desc: "Name" }
          optional :serial, type: String, documentation: { type: "String", desc: "Factory serial number" }
          optional :part_number, type: String, documentation: { type: "String", desc: "Factory part number" }
          optional :purchase_date, type: String, documentation: { type: "String", desc: "Purchase date as YYYY-MM-DD" }
          optional :warranty_end, type: String, documentation: { type: "String", desc: "Warranty end date as YYYY-MM-DD" }
          optional :seller, type: String, documentation: { type: "String", desc: "Seller" }
          optional :machine, type: String, documentation: { type: "String", desc: "machines FQDN if this inventoy is a machine" }
          optional :comment, type: String, documentation: { type: "String", desc: "Comment field" }
          optional :place, type: String, documentation: { type: "String", desc: "Additional place description" }
          optional :category, type: String, documentation: { type: "String", desc: "Additional category description" }
          optional :location_id, type: Integer, documentation: { type: "Integer", desc: "ID of the location" }
          optional :install_date, type: String, documentation: { type: "String", desc: "Installation date as YYYY-MM-DD" }
          optional :inventory_status_id, type: Integer, documentation: { type: "Integer", desc: "Inventory status id" }     
          optional :inventory_status, type: String, documentation: { type: "String", desc: "Inventory status, overrides inventory_status_id if set" }
        end
        put do
          can_write!
          i = Inventory.owned_by(@owner).find_by_inventory_number params[:inventory_number]
          error!('Not found', 404) unless i

          p = declared(params).to_h

          p["inventory_status_id"] = InventoryStatus.where(name: p["inventory_status"]).pluck(:id).first
          p.delete("inventory_status")

          i.update_attributes(p)

          present i
        end

        desc 'Delete a inventory'
        delete do
          can_write!
          i = Inventory.owned_by(@owner).find_by_inventory_number params[:inventory_number]
          error!('Not found', 404) unless i

          present i.destroy
        end
      end

      desc 'Return a list of inventories, possibly filtered', is_array: true,
                                                              success: Inventory::Entity
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

        query = Inventory.owned_by(@owner).all
        params.delete('idb_api_token')
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(Inventory.where(Inventory.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!('Bad Request', 400)
        end

        present query
      end

      desc 'Create a new inventory', success: Inventory::Entity
      params do
        requires :inventory_number, type: String, documentation: { type: "String", desc: "Inventory Number" }
        optional :name, type: String, documentation: { type: "String", desc: "Name" }
        optional :serial, type: String, documentation: { type: "String", desc: "Factory serial number" }
        optional :part_number, type: String, documentation: { type: "String", desc: "Factory part number" }
        optional :purchase_date, type: String, documentation: { type: "String", desc: "Purchase date as YYYY-MM-DD" }
        optional :warranty_end, type: String, documentation: { type: "String", desc: "Warranty end date as YYYY-MM-DD" }
        optional :seller, type: String, documentation: { type: "String", desc: "Seller" }
        optional :machine, type: String, documentation: { type: "String", desc: "machines FQDN if this inventoy is a machine" }
        optional :comment, type: String, documentation: { type: "String", desc: "Comment field" }
        optional :place, type: String, documentation: { type: "String", desc: "Additional place description" }
        optional :category, type: String, documentation: { type: "String", desc: "Additional category description" }
        optional :location_id, type: Integer, documentation: { type: "Integer", desc: "ID of the location" }
        optional :install_date, type: String, documentation: { type: "String", desc: "Installation date as YYYY-MM-DD" }
        optional :inventory_status_id, type: Integer, documentation: { type: "Integer", desc: "Inventory status id" }
        optional :inventory_status, type: String, documentation: { type: "String", desc: "Inventory status, overrides inventory_status_id if set" }
      end
      post do
        can_write!
        p = declared(params).to_h
        
        p["inventory_status_id"] = InventoryStatus.where(name: p["inventory_status"]).pluck(:id).first
        p.delete("inventory_status")

        i = Inventory.new(p)
        i.owner = @owner
        i.save!
        present i
      end
    end
  end
end
