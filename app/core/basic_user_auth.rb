class BasicUserAuth < Struct.new(:realm, :context)

  def authenticate(login, pass, otp = nil)
    validate(login, pass, otp) do |user|
      context.current_user = user
    end
  end

  def validate(login, pass, otp = nil, &block)
    validate_ldap(login, pass, otp, &block)
  end

  # currently disabled
  def validate_local(login, pass, otp = nil)
    user = User.find_by(login: login)
    return unless user
    
    if IDB.config.modules.otp_login
      if user && otp && user.try(:carLicence) && user.carLicence == otp[0,12]
        unless Rubius::Authenticator.authenticate(login, otp)
          return
        end
      end
    end

    if user.valid_password?(pass)
      yield(user) if block_given?
    end
    user
  end

  def validate_ldap(login, pass, otp = nil)
    ldap = LDAP::Connection.new(IDB.config.ldap)
    # this method is declared in app/core/ldap
    user = ldap.find_user(login, pass)

    # otp_login is active and carLicence attribute exists in LDAP
    if user && IDB.config.modules.otp_login && user.try(:carLicence)
      # OTP was entered at login and public parts match
      if otp && user.carLicence == otp[0,12]
        begin
          return unless Rubius::Authenticator.authenticate(login, otp)
        rescue RuntimeError => e
          # Rubius throws a RuntimeError if server does not respond
          puts e
          Raven.capture_exception(e)
          # continue without OTP validation
        end
      else
        return
      end
    end
    if user
      is_admin = ldap.is_admin?(login)
      yield(UserService.update_from_virtual_user(user, pass, is_admin)) if block_given?
    end
    user
  end
end
