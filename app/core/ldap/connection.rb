require 'net/ldap'
require 'ldap/user'

module LDAP
  class Connection
    @config

    def initialize(config)
      @config = config
      @uid = config.uid

      options = {
        base: config.base,
        host: config.host,
        port: config.port || 389 # SSL port: 636
      }

      if config.auth_dn && !config.auth_dn.empty?
        options[:auth] = {
          method: :simple,
          username: config.auth_dn,
          password: config.auth_password
        }
      end

      # Enable encryption if ldaps port is used.
      options[:encryption] = :simple_tls if options[:port] == 636
      options[:encryption] = :simple_tls if config.tls == "yes"

      @ldap = Net::LDAP.new(options)
    end

    def find_user(login, password)
      filter = Net::LDAP::Filter.eq(@uid, login)
      response = @ldap.bind_as(:filter => filter, :password => password)

      response ? LDAP::User.new(response.first) : false
    end

    def is_admin?(dn)
      if @config.admin_group.blank?
        return true
      else
        if @ldap.bind
          filter = Net::LDAP::Filter.eq(@config.group_membership_attribute, dn)
          result = @ldap.search(base: @config.base, filter: filter)
          result.each do |entry|
            return true if entry.dn == @config.admin_group
          end
        else
          puts "error on LDAP bind: " + @ldap.get_operation_result
        end
      end
      false
    end
  end
end
