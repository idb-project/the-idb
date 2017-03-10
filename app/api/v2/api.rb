module V2
  class API < Grape::API
    mount V2::Machines
    mount V2::CloudProviders
    mount V2::Inventories
  end
end
