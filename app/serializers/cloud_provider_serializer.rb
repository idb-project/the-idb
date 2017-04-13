class CloudProviderSerializer < ActiveModel::Serializer
  attributes :owner_id, :name, :description, :config, :apidocs
end
