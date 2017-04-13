module V3
  class API < Grape::API
    mount V3::Machines
    # mount V3::CloudProviders
    # mount V3::Inventories
    # mount V3::Software
  end
end
