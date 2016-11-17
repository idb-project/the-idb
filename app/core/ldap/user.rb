module LDAP
  class User
    attr_reader :dn, :name, :login, :email, :carLicence

    def initialize(ldap_entry)
      @dn = Array(ldap_entry[:dn]).first
      @name = ldap_entry[:cn].first
      @login = ldap_entry[IDB.config.ldap.uid].first
      @email = ldap_entry[:mail].first
      @carLicence = ldap_entry[:carLicense].first
    end

    def attributes
      {login: login, name: name, email: email, carLicence: carLicence}
    end
  end
end
