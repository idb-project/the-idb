class Network < ActiveRecord::Base
  serialize :preferences

  has_paper_trail

  # Make sure we have a hash in #preferences.
  after_initialize { self.preferences ||= {} }

  belongs_to :owner

  validates :name, :address, presence: true
  validates :name, uniqueness: true

  validates_each :address do |record, attribute, value|
    begin
      ::IPAddress::IPv4.new(value.to_s)
    rescue ArgumentError => e
      record.errors.add(attribute, e.message)
    end
  end

  def self.owned_by(o)
    where(owner: o)
  end

  def self.default_scope
    if User.current.nil? || User.current.is_admin?
      nil
    else
      -> { where(owner: User.current.owners.to_a) }
    end
  end

  def ip
    return if address.blank? # Do not try to parse if missing.
    ::IPAddress.parse(address)
  end

  def ip_addresses
    IpAddress.where(addr: ip.hosts.map(&:address))
    ret = []
    IpAddress.all.each do |i|
      if i.nic && i.nic.machine && i.nic.machine.owner && i.nic.machine.owner == owner
        ret << i
      end
    end
    ret
  end

  def allowed_ip_addresses
    preferences[:allowed_ip_addresses] || []
  end

  def allowed_ip_addresses=(values)
    values = values.is_a?(Array) ? values : [values]

    preferences[:allowed_ip_addresses] = values.map(&:to_s).reject(&:blank?).tap do |v|
      # Make sure the changes end up in the paper_trail.
      attribute_will_change!('preferences')
    end
  end

  # XXX This should be somewhere else!
  def allowed_ip_addresses_with_hosts
    machines = ip_addresses.each_with_object({}) do |ip, hash|
      hash[ip.addr] = ip.machine
    end

    ip.hosts.map do |host|
      name = machines[host.to_s] ? "(#{machines[host.to_s].name})" : ''
      ["#{host.to_s} #{name}" || host.to_s, host.to_s]
    end
  end

  def ordered_versions
    PaperTrail::Version.with_item_keys(self.class.name, id).order(created_at: :desc)
  end
end
