class ApiToken < ActiveRecord::Base
  validates :token, presence: true, uniqueness: true
  validates :name, presence: true

  belongs_to :owner
  belongs_to :machine
end
