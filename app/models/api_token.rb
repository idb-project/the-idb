class ApiToken < ActiveRecord::Base
  validates :token, presence: true, uniqueness: true
  validates :name, presence: true
end
