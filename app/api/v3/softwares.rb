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
        @owners = get_owners
      end

      desc 'Searches machines with specific software configurations', is_array: true,
        success: Machine::Entity
        params do
          requires :q, type: String, documentation: { desc: "search query, for example 'nmap=4'", param_type: "query" }
        end
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
          machines = SoftwareHelper.software_machines(Machine.owned_by(@owners), software, versions)
          status 200
          machines.map(&:fqdn)
        end
      end
    end
  end
end
