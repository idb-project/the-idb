class UserService
  def self.update_from_virtual_user(vuser, password = nil, admin = false)
    user = User.find_or_initialize_by(login: vuser.login) do |user|
      user.name = vuser.name
      user.email = vuser.email
      user.carLicence = vuser.carLicence
    end

    # Make sure the local password gets updated!
    user.password = password if password

    user.admin = admin

    if user.new_record?
      user.save!
    else
      user.update!(vuser.attributes)
    end

    user
  end
end
