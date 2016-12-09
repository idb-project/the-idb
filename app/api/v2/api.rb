module V2
  class API < Grape::API
    mount V2::Machines
    mount V2::CloudProviders
  end
end
