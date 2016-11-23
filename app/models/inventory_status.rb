class InventoryStatus < ActiveRecord::Base

  has_many :inventories
  validates :name, presence: true, uniqueness: true

end
