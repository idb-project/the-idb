module V3
  class Inventories < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json

    resource :inventories do
      before do
        api_enabled!
        authenticate!
        set_papertrail
        @owner = get_owner
        @owners = get_owners
      end

      route_param :inventory_number, type: String do
        resource :attachments do
          route_param :fingerprint, type: String, requirements: { fingerprint: /[a-f0-9]+/ } do
            desc 'Get an attachment',
              success: Attachment::Entity
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
            i = Inventory.owned_by(@owners).find_by_inventory_number params[:inventory_number]
            error!('Not Found', 404) unless i

            present i.attachments
          end

          desc 'Create an attachment',
            success: Attachment::Entity
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

        desc 'Get a inventory by inventory number',
          success: Inventory::Entity
        get do
          can_read!
          i = Inventory.owned_by(@owners).find_by_inventory_number params[:inventory_number]
          error!('Not found', 404) unless i

          set_token item_update_token(i)

          present i
        end

        desc 'Update a single inventory',
          params: Inventory::Entity.documentation,
          success: Inventory::Entity
        put do
          can_write!
          i = Inventory.owned_by(@owner).find_by_inventory_number params[:inventory_number]
          error!('Not found', 404) unless i

          params["inventory_status_id"] = InventoryStatus.where(name: params["inventory_status"]).pluck(:id).first
          params.delete("inventory_status")

          begin
            i.update_attributes(params)
          rescue
            error!('Invalid Machine', 409)
          end

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

      desc 'Return a list of inventories, possibly filtered',
        is_array: true,
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

        query = Inventory.owned_by(@owners).all
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

      desc 'Create a new inventory',
        params: Inventory::Entity.documentation,
        success: Inventory::Entity
      post do
        can_write!
        
        params["inventory_status_id"] = InventoryStatus.where(name: params["inventory_status"]).pluck(:id).first
        params.delete("inventory_status")

        i = Inventory.new(params)
        i.owner = @owner
        i.save!
        present i
      end
    end
  end
end
