class MachinePresenter < Keynote::Presenter
  presents :machine

  delegate :arch, :nics, :os, :os_release, :serialnumber,
           :owner, :switch?,
           :unattended_upgrades, :unattended_upgrades_reboot,
           :pending_updates, :pending_security_updates,
           :pending_updates_sum, :virtual?,
           :backup_last_full_run, :backup_last_inc_run,
           :backup_last_diff_run, :is_backed_up?, :connected_to_power_feed?, :software,
           :device_type,
           to: :machine

  def id
    machine.id
  end

  def name_link
    link_to(machine.name, machine)
  end

  def owner_link
    link_to(machine.owner.display_name, machine.owner) if machine.owner
  end

  def description
    TextileRenderer.render(machine.description) if machine.description
  end

  def alias_names
    machine.aliases.map(&:name).join(', ')
  end

  def power_feed_a
    machine.power_feed_a.nil? ? "" : machine.power_feed_a.name
  end

  def power_feed_b
    machine.power_feed_b.nil? ? "" : machine.power_feed_b.name
  end

  def power_feed_a_location_name
    machine.power_feed_a.nil? ? "" : k(machine.power_feed_a).location_name
  end

  def power_feed_b_location_name
    machine.power_feed_b.nil? ? "" : k(machine.power_feed_b).location_name
  end

  def first_ip
    return if machine.nics.empty?

    eth0 = machine.nics.find {|n| n.name == 'eth0' }

    eth0 ? eth0.ipv4addr : machine.nics.first.ipv4addr
  end

  def first_v6_ip
    return if machine.nics.empty?

    eth0 = machine.nics.find {|n| n.name == 'eth0' }

    eth0 ? eth0.ipv6addr : machine.nics.first.ipv6addr
  end

  def v6_img
    first_v6_ip.blank? ? "v6_off.png" : "v6.png"
  end

  def os
    "#{machine.os} #{machine.os_release}"
  end

  def ram
    if machine.ram
      if machine.ram < 1000
        "0." + machine.ram.to_s[0..1] + " GB"
      elsif machine.ram < 1025
        "1.00 GB"
      else
        number_to_human_size(machine.ram * 1024 * 1024)
      end
    end
  end

  def cores
    machine.cores || 0
  end

  # def device_type
  #   machine.device_type.name if machine.device_type
  # end

  def uptime
    # Do not show the uptime if the machine hasn't been updated in a while.
    # Will avoid confusion if the facts haven't been updated in a while.
    return if machine.outdated?

    rounded = (machine.uptime / 60 / 60 / 24) if machine.uptime
    if rounded == 0
      # show 0.4 for example if uptime is less than 1 day
      rounded = (machine.uptime / 60 / 60 * 10 / 24).round(1) / 10
    end

    rounded
  end

  def created_at
    machine.created_at.localtime if !machine.created_at.nil?
  end

  def updated_at
    machine.updated_at.localtime if !machine.updated_at.nil?
  end

  def vmhost
    unless machine.instance_of? VirtualMachine
      return "n/a"
    end

    return if machine.vmhost.blank?

    parts = machine.vmhost.split('.')

    case parts.size
    when 6
      parts[0, 4].join('.')
    when 5
      parts[0, 3].join('.')
    when 4
      parts[0, 2].join('.')
    when 3
      parts[0, 1].join('.')
    else
      parts.join('.')
    end
  end

  def backup_type
    machine.backup_type_string
  end

  def backup_brand
    machine.backup_brand_string
  end

  def backup_last_full_size
    number_to_human_size(machine.backup_last_full_size)
  end

  def backup_last_inc_size
    number_to_human_size(machine.backup_last_inc_size)
  end

  def backup_last_diff_size
    number_to_human_size(machine.backup_last_diff_size)
  end

  def backup_size_sum
    sum = 0
    sum+= machine.backup_last_full_size unless machine.backup_last_full_size.blank?
    sum+= machine.backup_last_inc_size unless machine.backup_last_inc_size.blank?
    sum+= machine.backup_last_diff_size unless machine.backup_last_diff_size.blank?
    sum > 0 ? number_to_human_size(sum) : ""
  end

  def backup_sizes_present?
    if machine.backup_last_full_size.blank? && machine.backup_last_inc_size.blank? && machine.backup_last_diff_size.blank?
      false
    else
      true
    end
  end

  def serviced_at
    machine.serviced_at.localtime.strftime('%F') if machine.serviced_at
  end

  def maintenance_records
    machine.maintenance_records.order('created_at DESC')
  end

  def auto_update
    machine.auto_update
  end

  def outdated
    machine.outdated?
  end

  def unattended_upgrades_column
    if machine.unattended_upgrades
      if machine.unattended_upgrades_reboot
        "auto reboot"
      else
        "no reboot"
      end
    else
      "no"
    end
  end

  def unattended_upgrades_reboot_string
    machine.unattended_upgrades ? "yes" : "no"
  end

  def needs_reboot_string
    machine.needs_reboot? ? "yes" : "no"
  end

  def unattended_upgrades_blacklisted_packages
    # double yaml encoded
    if machine.unattended_upgrades_blacklisted_packages && !YAML::load(machine.unattended_upgrades_blacklisted_packages).empty?
      content = YAML::load(machine.unattended_upgrades_blacklisted_packages).first
      unless content.nil?
        content = YAML::load(content)
        unless content.empty?
          html = "<ul>"
          content.each do |p| html += "<li>#{p}</li>" end
          html += "</ul>"
          return html unless html.blank?
        end
      end
    end
    return "-"
  end

  def unattended_upgrades_time
    return "-" unless machine.unattended_upgrades_time

    # fact is returned as "hour.min", e.g. "5.4". Make it human readable
    str = machine.unattended_upgrades_time
    hours = str.split(".")[0]
    hours = "0"+hours if hours.length == 1
    minutes = str.split(".")[1]
    minutes = "0"+minutes if minutes.length == 1

    hours+":"+minutes
  end

  def unattended_upgrades_repos
    # double yaml encoded, example: "---\n- ! '[\"security\", \"updates\"]'\n"
    if machine.unattended_upgrades_repos && !YAML::load(machine.unattended_upgrades_repos).empty?
      content = YAML::load(machine.unattended_upgrades_repos).first
      unless content.nil?
        content = YAML::load(content)
        unless content.empty?
          html = "<ul>"
          content.each do |p| html += "<li>#{p}</li>" end
          html += "</ul>"
          return html unless html.blank?
        end
      end
    end
    return "-"
  end

  def pending_updates_sum
    machine.pending_updates_sum.to_s
  end

  def pending_security_updates
    machine.pending_security_updates.to_s.blank? ? "" : machine.pending_security_updates.to_s
  end

  def pending_updates_package_names_list
    list = Array.new
    if machine.pending_updates_package_names && !YAML::load(machine.pending_updates_package_names).empty?
      content = YAML::load(machine.pending_updates_package_names).first
      unless content.nil?
        # Result looks like this, some gsubbing is needed
        # "[libpython2.7 python2.7-minimal ]"
        list = content.gsub("[", "").gsub("]", "").split(" ")
      end
    end
    return list
  end

  def pending_updates_package_names
    list = pending_updates_package_names_list
    unless list.empty?
      html = "<ul>"
      list.each do |p| html += "<li>#{p}</li>" end
      html += "</ul>"
      return html unless html.blank?
    end
    return "none"
  end

  def config_instructions
    machine.config_instructions? ? machine.config_instructions : ""
  end

  def sw_characteristics
    machine.sw_characteristics? ? machine.sw_characteristics : ""
  end

  def business_purpose
    machine.business_purpose? ? machine.business_purpose : ""
  end

  def business_criticality
    machine.business_criticality? ? machine.business_criticality : ""
  end

  def business_notification
    machine.business_notification? ? machine.business_notification : ""
  end

  def diskspace
    number_to_human_size(machine.diskspace)
  end

  def fqdn
   machine.fqdn
  end

  def attachment_list
    return "none" if (machine.attachments && machine.attachments.size == 0)

    list = "<ul>"
    machine.attachments.each do |att|
      list += "<li><a href='#{att.attachment.url}' target='_blank'>#{att.attachment_file_name}</a></li>"
    end
    list += "</ul>"
  end

  def puppetdb_data
    output = ""
    if machine.raw_data_puppetdb
      JSON.parse(machine.raw_data_puppetdb).each do |h|
        output += "#{h['name']}: #{h['value']}<br/>"
      end
    end
    output
  end

  def api_data
    output = ""
    if machine.raw_data_api
      raw = JSON.parse(machine.raw_data_api)
      raw.keys.each do |k|
        output += "#{k}: #{raw[k]}<br/>"
      end
    end
    output
  end
end
