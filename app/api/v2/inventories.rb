module V2
  class Inventories < Grape::API
    helpers V2::Helpers

    version 'v2'
    format :json

    resource :inventories do
      before do
        api_enabled!
        authenticate!
        can_read!
      end

      get do
        if params[:id] != nil
          Inventory.find_by id: params[:id]
        else
          Inventory.all
        end        
      end
    end
  end
end
