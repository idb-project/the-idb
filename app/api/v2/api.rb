module V2
  class API < Grape::API
    mount V2::Machines
  end
end
