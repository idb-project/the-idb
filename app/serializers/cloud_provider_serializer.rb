class CloudProviderSerializer < ActiveModel::Serializer
  attributes :name, :description, :config, :apidocs
end
