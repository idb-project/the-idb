module V3
  class CloudProviders < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    resource :cloud_providers do
      before do
        api_enabled!
        authenticate!
        set_papertrail
      end

      desc "Get cloud provider by name"
      get ':name', requirements: {number: /[a-zA-Z0-9.]+/ } do
        c = CloudProvider.find_by_name params[:name]
        error!("Not found", 404) unless c

        c
      end
    end
  end
end