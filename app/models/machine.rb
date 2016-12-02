class Machine < ActiveRecord::Base
  BackupType = {
    0 => 'no',
    1 => 'yes',
    2 => 'not-needed',
    3 => 'not responsible'
  }.freeze

  BackupBrand = {
    0 => '',
    1 => 'Bacula',
    2 => 'SEP',
    3 => 'BackupPC',
    4 => 'File'
  }.freeze

  # http://stackoverflow.com/questions/11809631/fully-qualified-domain-name-validation
  FQDN_REGEX = /(?=^.{4,255}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)/

  acts_as_paranoid if IDB.config.modules.softdelete

  has_paper_trail :ignore => [:uptime, :updated_at, :unattended_upgrades, :unattended_upgrades_blacklisted_packages,
      :unattended_upgrades_reboot, :unattended_upgrades_time, :unattended_upgrades_repos,
      :pending_updates, :pending_security_updates, :pending_updates_sum, :pending_updates_package_names,
      :backup_last_full_run, :backup_last_inc_run, :backup_last_diff_run, :backup_last_full_size,
      :backup_last_inc_size, :backup_last_diff_size,
      :serviced_at, :raw_data_api, :raw_data_puppetdb, :needs_reboot]

  has_many :nics, dependent: :destroy, autosave: true
  has_many :maintenance_records, dependent: :destroy, autosave: true
  has_many :aliases, class_name: 'MachineAlias', dependent: :destroy, autosave: true
  has_many :attachments, :dependent => :destroy
  belongs_to :owner
  belongs_to :inventory
  belongs_to :power_feed_a, class_name: 'Location', foreign_key: 'power_feed_a'
  belongs_to :power_feed_b, class_name: 'Location', foreign_key: 'power_feed_b'
  
  validates :fqdn, presence: true, uniqueness: true
  validates :fqdn, format: {with: FQDN_REGEX}

  def self.create_switch!(attributes = {})
    create(attributes.merge(device_type_id: 3))
  end

  def self.is_switch?(fqdn)
    exists?(fqdn: fqdn, device_type_id: 3)
  end

  def self.switches
    where(device_type_id: 3)
  end

  def switch?
    device_type && device_type.name == 'switch'
  end

  def switch_ports
    switch? ? SwitchPort.where(switch_id: id) : []
  end

  def virtual?
    device_type && device_type.name == 'virtual'
  end

  def name
    fqdn
  end

  def device_type
    DeviceType.find(device_type_id)
  end

  def device_type=(type)
    self.device_type_id = type.id if type
  end

  def backup_type_string
    BackupType.fetch(backup_type, '')
  end

  def backup_brand_string
    BackupBrand.fetch(backup_brand, '')
  end

  def is_backed_up?
    backup_type == 1
  end

  def manual?
    !auto_update
  end

  def outdated?
    !updated_at || updated_at < 1.day.ago
  end

  def needs_reboot?
    needs_reboot == 1
  end

  def connected_to_power_feed?
    !power_feed_a.nil? || !power_feed_b.nil?
  end

  def power_supply_name(location)
    if power_feed_a == location
      "A"
    elsif power_feed_b == location
      "B"
    end
  end

  def ordered_versions
    PaperTrail::Version.with_item_keys(self.class.name, id).order(created_at: :desc)
  end

  def local_part
    return unless name

    parts = name.split('.')

    if parts.size > 0
      parts[0]
    else
      name
    end
  end

  def update_details(params, machine_details)
    machine_params = params.require(:machine).permit([
      :arch, :ram, :cores, :serialnumber, :device_type_id, :vmhost, :os,
      :os_release, :switch_url, :mrtg_url, :raw_data_api,
      {nics: [:name, :mac, :remove, {ip_address: [:addr, :netmask, :addr_v6]}]},
      {aliases: [:name, :remove]}, :needs_reboot
    ])

    machine_details.update(machine_params)
  end

  def update_details_by_api(params, machine_details)
    machine_details.update(params)
  end
end
