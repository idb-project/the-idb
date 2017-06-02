class OwnerApiToken < ActiveRecord::Base
  belongs_to :owner
  belongs_to :api_token
end