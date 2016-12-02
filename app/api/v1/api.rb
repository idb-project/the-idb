module V1
  class API < Grape::API
    mount V1::Machines
  end
end
