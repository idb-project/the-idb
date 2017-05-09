require 'grape-swagger'

module V3
  class API < Grape::API
    mount V3::Machines
    mount V3::CloudProviders
    mount V3::Inventories
    mount V3::Softwares
    mount V3::Switches
    mount V3::Nics
    mount V3::Locations
    add_swagger_documentation mount_path: "/v3/swagger_doc"
  end
end
