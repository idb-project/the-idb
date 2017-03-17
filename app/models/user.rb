class User < ActiveRecord::Base
  acts_as_paranoid
  has_and_belongs_to_many :owners
  
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
end
