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
      end

      route_param :number, type: String do
        resource :attachments do
          route_param :fingerprint, type: String, requirements: { fingerprint: /[a-f0-9]+/ } do
            desc 'Get an attachment', detail: 'WAT?',
                                      success: Attachment::Entity
            get do
              can_read!
              a = Attachment.find_by_attachment_fingerprint params[:fingerprint]
              error!('Not Found', 404) unless a

              present a
            end

            desc 'Delete an attachment'
            delete do
              can_write!
              a = Attachment.find_by_attachment_fingerprint params[:fingerprint]
              error!('Not Found', 404) unless a

              a.destroy!
            end
          end

          desc 'Get all attachments', is_array: true,
                                      success: Attachment::Entity
          get do
            can_read!
            i = Inventory.find_by_inventory_number params[:number]
            error!('Not Found', 404) unless i

            present i.attachments
          end

          desc 'Create an attachment', success: Attachment::Entity
          post do
            can_write!
            i = Inventory.find_by_inventory_number params[:number]
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
          i = Inventory.find_by_inventory_number params[:number]
          error!('Not found', 404) unless i

          present i
        end

        desc 'Update a single inventory', success: Inventory::Entity
        put do
          can_write!
          i = Inventory.find_by_inventory_number params[:number]
          error!('Not found', 404) unless i

          p = params.select { |k| Inventory.attribute_method?(k) }

          i.update_attributes(p)

          present i
        end

        desc 'Delete a inventory'
        delete do
          can_write!
          i = Inventory.find_by_inventory_number params[:number]
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

        query = Inventory.all
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
      post do
        can_write!
        p = params.select { |k| Inventory.attribute_method?(k) }
        i = Inventory.create(p)
        present i
      end
    end
  end
end
