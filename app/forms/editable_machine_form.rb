class EditableMachineForm
  include ActiveModel::Model
  include ActiveModel::Validations

  def self.model_name
    ActiveModel::Name.new(Machine)
  end

  delegate :fqdn, :arch, :ram, :cores, :vmhost, :description,
           :os, :os_release, :serialnumber,
           :switch_url, :mrtg_url, :config_instructions, :device_type,
           :sw_characteristics, :business_purpose, to: :machine

  delegate :nics, :aliases, to: :machine

  attr_reader :machine

  delegate :name, :new_record?, to: :machine

  validate do |form|
    unless @parms["nics"].blank?
      @parms["nics"].each do |nic|
        next if nic["name"].blank?

        index = form.machine.nics.find_index{|n| n.name == nic["name"]}
        nic_obj = nil
        unless index.nil?
          nic_obj = form.machine.nics[index]
        end

        if nic["ip_address"]["addr"].blank?
          form.errors.add(nic_obj.name, 'ip address missing')
        end

        if nic["ip_address"]["netmask"].blank?
          form.errors.add(nic_obj.name, 'netmask missing')
        end
      end
    end
  end

  def initialize(machine)
    @machine = machine
    @show_errors = false
  end

  def show_errors?
    !!@show_errors
  end

  def update(params)
    case params["device_type"]
      when "Machine"
        @machine.becomes!(Machine)
      when "Virtual Machine"
        @machine.becomes!(VirtualMachine)
      when "Switch"
        @machine.becomes!(Switch)
    end

    params.permit! if params.is_a? ActionController::Parameters
    @parms = params.to_h.clone
    params = params.to_h

    nics = params.delete(:nics)
    nics = recursive_symbolize_keys(nics) || Array.new

    aliases = params.delete(:aliases) || Array.new
    aliases = recursive_symbolize_keys(aliases)

    nics_changed = false

    # if nic parameters are presented delete all nics and create them from scratch
    @machine.nics.destroy_all if nics.size > 0

    params.keys.each do |key|
      next unless machine.respond_to?("#{key}=")
      machine.public_send("#{key}=", params[key])
    end

    nics.each do |data|
      next if data[:name].blank?

      ip_address = data.delete(:ip_address)
      next if data[:remove] # NIC has been marked to remove, ignore its params
      nic = nic_for(data)
      return false unless nic

      nic.update(mac: data[:mac])
      nics_changed = true
      nic.ip_address || nic.build_ip_address(family: 'inet')
      nic.ip_address.update(ip_address) if ip_address
    end

    aliases.each do |data|
      next if data[:name].blank?

      aliass = alias_for(data)

      next if aliass.destroyed?
    end

    begin
      changed_attributes = machine.changed_attributes
      if valid? && machine.save
        changed_attributes.empty? ? {} : changed_attributes
      else
        @show_errors = true
        nil
      end
    rescue ActiveRecord::RecordNotUnique => error
      @show_errors = true
      str = $!.message
      # extract the alias from the MySQL message "Duplicate entry 'xyz' for"
      self.errors.add('Alias', 'already exists: '+str[str.index("entry '")+7, str.index("' for")-(str.index("entry '")+7)])
      false
    end
  end

  def nic_for(data)
    return if data.nil? || data[:name].blank?
    nic =  machine.nics.where(name: data[:name]).first
    machine.nics.build(data)
  end

  def alias_for(data)
    remove = data.delete(:remove)
    aliass =  machine.aliases.where(name: data[:name]).first

    if aliass
      # Destroy the alias if the remove flag has been set.
      remove ? aliass.destroy : aliass
    else
      machine.aliases.build(data)
    end
  end

  def arch_list
    %w(amd64 i386)
  end

  def core_collection
    [1] + 2.step(48, 2).to_a # Show even number of cores.
  end

  def device_types
    return ["Machine","Virtual Machine","Switch"]
  end

  def vmhost_list
    Machine.where("type = 'Machine'")
  end

  def os_list
    (
      Machine.select(:os).distinct.map(&:os).compact + os_other
    ).sort
  end

  def os_release_list
    (
      Machine.select(:os_release).distinct.map(&:os_release).compact + os_release_other
    ).sort
  end

  def to_model
    machine
  end
  
  def mrtg_url
    machine.mrtg_url ? machine.mrtg_url : IDB.config.mrtg.base_url
  end

  private

  def os_other
    IDB.config.machine_details.os
  end

  def os_release_other
    IDB.config.machine_details.os_release
  end

  def recursive_symbolize_keys(my_hash)
    case my_hash
    when Hash
      Hash[
        my_hash.map do |key, value|
          [ key.respond_to?(:to_sym) ? key.to_sym : key, recursive_symbolize_keys(value) ]
        end
      ]
    when Enumerable
      my_hash.map { |value| recursive_symbolize_keys(value) }
    else
      my_hash
    end
  end
end
