module V2
  class Software < Grape::API
    helpers V2::Helpers

    version 'v2'
    format :json

    resource :software do
      before do
        api_enabled!
        authenticate!
      end

      get do
        can_read!
        machines = SoftwareHelper.software_machines(Machine.all, params["package"], params["version"])
        status 200
        machines
      end
    end
  end
end
