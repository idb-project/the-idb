class ApiToken < ActiveRecord::Base
  has_many :owner_api_tokens
  has_many :owners, through: :owner_api_tokens

  validates :token, presence: true, uniqueness: true
  validates :name, presence: true
end
