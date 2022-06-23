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
          requires :package, type: String, documentation: { desc: "search query, for example 'nmap'", param_type: "query" }
        end
      get do
        can_read!
        machines = SoftwareHelper.software_machines(Machine.owned_by(@owners), params["package"], params["version"])
        status 200
        machines.map(&:fqdn)
      end
    end
  end
end
