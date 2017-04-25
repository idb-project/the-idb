module V2
  class API < Grape::API
    mount V2::Machines
    mount V2::CloudProviders
    mount V2::Inventories
    mount V2::Software
  end
end
