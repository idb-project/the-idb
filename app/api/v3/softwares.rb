module V3
  class Softwares < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json

    resource :softwares do
      before do
        api_enabled!
        authenticate!
      end

      desc "Searches machines with specific software configurations"
      get do
        can_read!
        if params["q"].empty?
            status 200
            {}
        else
          software,versions = SoftwareHelper.parse_query(params["q"])
          if software.empty?
            status 200
            []
          end
          machines = SoftwareHelper.software_machines(software, versions)
          status 200
          machines.map { |m| m.fqdn }
        end        
      end
    end
  end
end