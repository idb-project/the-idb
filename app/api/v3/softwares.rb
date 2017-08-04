module V3
  class Softwares < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json

    resource :softwares do
      before do
        api_enabled!
        authenticate!
        @owner = get_owner
      end

      desc 'Searches machines with specific software configurations', is_array: true,
                                                                      success: Machine::Entity
      get do
        can_read!
        if params['q'].empty?
          status 200
          []
        else
          software, versions = SoftwareHelper.parse_query(params['q'])
          if software.empty?
            status 200
            []
          end
          machines = SoftwareHelper.software_machines(Machines.owned_by(@owner), software, versions)
          status 200
          machines.map(&:fqdn)
        end
      end
    end
  end
end
