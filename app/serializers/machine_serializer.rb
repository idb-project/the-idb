class MachineSerializer < ActiveModel::Serializer
  attributes :fqdn,:os,:arch,:ram,:cores,:vmhost,:serviced_at,:description,:deleted_at,:created_at,:updated_at,:os_release,:uptime,:device_type_id,:serialnumber,:owner_id,:backup_type,:auto_update,:switch_url,:mrtg_url,:config_instructions,:sw_characteristics ,:business_purpose,:business_criticality,:business_notification,:unattended_upgrades,:unattended_upgrades_blacklisted_packages,:unattended_upgrades_reboot,:unattended_upgrades_time,:unattended_upgrades_repos,:pending_updates,:pending_security_updates,:pending_updates_sum,:diskspace,:pending_updates_package_names,:severity_class,:ucs_role,:backup_brand,:backup_last_full_run,:backup_last_inc_run,:backup_last_diff_run,:raw_data_api,:raw_data_puppetdb,:backup_last_full_size,:backup_last_inc_size,:backup_last_diff_size,:needs_reboot,:software,:aliases,:power_feed_a_id,:power_feed_b_id,:nic_ids
  
  def nic_ids
    object.nics.map {|p| p.id}
  end

  def power_feed_a_id
    object.power_feed_a.id
  end

  def power_feed_b_id
    object.power_feed_b.id
  end

  has_many :aliases
end
