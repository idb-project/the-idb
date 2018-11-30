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
        if params["q"].empty?
            status 200
            {}
        else
          parsed = SoftwareHelper.parse_query(params["q"])
          if parsed.empty?
            status 200
            []
          end
          machines = SoftwareHelper.software_machines(Machine.all, parsed)
          status 200
          machines
        end        
      end
    end
  end
end
