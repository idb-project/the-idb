class User < ActiveRecord::Base
  acts_as_paranoid
  has_and_belongs_to_many :owners
  has_many :maintenance_announcements
  
  has_secure_password validations: false

  def display_name
    name.blank? ? login : name
  end

  # Update user attributes but keep existing value if the new value is nil or
  # empty.
  def update(attributes)
    attributes.each do |key, value|
      attributes.delete(key) if value.blank?
    end

    super(attributes)
  end

  def valid_password?(password)
    !!(!password_digest.blank? && authenticate(password))
  end

  def is_admin?
    admin || false
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def associates
    users = []
    owners.each do |o|
      o.users.each do |u|
        users.push(u) unless users.include?(u)
      end
    end
    users
  end

  def rtname
    login
  end
end
