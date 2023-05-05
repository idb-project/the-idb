class KCloudReport < ActiveRecord::Base
  belongs_to :machine

  class Entity < Grape::Entity
    expose :ip, documentation: { type: "String", desc: "IP of the reporting system", param_type: "body" }
    expose :raw_data, documentation: { type: "Text", desc: "raw report", param_type: "body" }
  end
end
