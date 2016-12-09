class CloudProvider < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  belongs_to :owner
end
