module V3
  class Inventories < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    resource :inventories do
      before do
        api_enabled!
        authenticate!
        set_papertrail
      end

      route_param :number do

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
            i = Inventory.find_by_inventory_number params[:number]
            error!("Not Found", 404) unless i

            i.attachments
          end

          desc "Create an attachment"
          post do
            can_write!
            i = Inventory.find_by_inventory_number params[:number]
            error!("Not Found", 404) unless i

            x = {
            filename: params[:data][:filename],
            size: params[:data][:tempfile].size,
            tempfile: params[:data][:tempfile]
            }
            
            attachment = ActionDispatch::Http::UploadedFile.new(x)

            i.attachments.create(attachment: attachment)
          end
        end

        desc "Get a inventory by inventory number"
        get do
          can_read!
          i = Inventory.find_by_inventory_number params[:number]
          error!("Not found", 404) unless i

          i
        end

        desc "Update a single inventory"
        put do
          can_write!
          i = Inventory.find_by_inventory_number params[:number]
          error!("Not found", 404) unless i

          p = params.reject { |k| !Inventory.attribute_method?(k) }

          i.update_attributes(p)

          i
        end

        desc "Delete a inventory"
        delete do
          can_write!
          i = Inventory.find_by_inventory_number params[:number]
          error!("Not found", 404) unless i

          i.destroy
        end
      end

      desc "Return a list of inventories, possibly filtered"
      get do
        can_read!

        if params["machine"] 
          if Machine.find_by_fqdn(params["machine"])
            params[:machine_id] = Machine.find_by_fqdn(params["machine"]).id
          else
            return []
          end
        end
        params.delete "machine"

        query = Inventory.all
        params.delete("idb_api_token")
        params.each do |key, value|
          keysym = key.to_sym
          query = query.merge(Inventory.where(Inventory.arel_table[keysym].eq(value)))
        end

        begin
          query.any?
        rescue ActiveRecord::StatementInvalid
          error!("Bad Request", 400)
        end

        query
      end

      desc 'Create a new inventory'
      post do
        can_write!
        p = params.reject { |k| !Inventory.attribute_method?(k) }
        i = Inventory.create(p)
        i
      end
    end
  end
end