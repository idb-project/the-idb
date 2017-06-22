class CloudProvider < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  belongs_to :owner

  def self.default_scope
    if User.current.nil? || User.current.is_admin?
      nil
    else
      -> { where(owner: User.current.owners) }
    end
  end
end
