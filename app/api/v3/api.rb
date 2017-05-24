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
    add_swagger_documentation mount_path: '/v3/swagger_doc', base_path: '/api', add_base_path: true, models: [Machine::Entity], info: { title: 'IDB API', description: 'Infrastructure Database v3', contact_name: 'bytemine GmbH', contact_email: 'support@bytemine.net', contact_url: 'https://bytemine.net', license: 'GNU AFFERO GENERAL PUBLIC LICENSE Version 3', license_url: 'https://www.gnu.org/licenses/agpl-3.0.txt' }
  end
end
