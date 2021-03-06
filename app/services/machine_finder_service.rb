class MachineFinderService
  def initialize(redis)
    @list = UntrackedMachinesList.new(redis)
    @puppet_nodes = []
    @oxidized_nodes = []

    if IDB.config.puppetdb
      v3_urls = IDB.config.puppetdb.api_urls.map { |u| [u["url"]] if u["version"] == "v3" }.flatten.compact
      @puppet_nodes = Puppetdb::Nodes.new(v3_urls).all

      v4_urls = IDB.config.puppetdb.api_urls.map { |u| [u["url"]] if u["version"] == "v4" }.flatten.compact
      @puppet_nodes += Puppetdb::NodesV4.new(v4_urls).all
    end

    if IDB.config.oxidized
      oxidized_urls = IDB.config.oxidized.api_urls.map { |u| [u["url"]] }.flatten.compact
      @oxidized_nodes = Oxidized::Nodes.new(oxidized_urls).all
    end
  end

  def find_untracked_machines
    puppet_nodes = @puppet_nodes
    oxidized_nodes = @oxidized_nodes
    machines = Machine.pluck(:fqdn)
    machine_aliases = MachineAlias.pluck(:name)
    puppet_untracked = puppet_nodes - machines - machine_aliases
    oxidized_untracked = oxidized_nodes - machines - machine_aliases

    if IDB.config.puppetdb
      if IDB.config.puppetdb.auto_create
        update_untracked(puppet_untracked, "PuppetDB")
      else
        # Set all nodes that are not in the database to the untracked machines
        # list.
        @list.set(puppet_untracked)
      end
    end

    if IDB.config.oxidized
      if IDB.config.oxidized.auto_create
        update_untracked(oxidized_untracked, "Oxidized")
      else
        # Add all nodes that are not in the database to the untracked machines
        # list.
        @list.add(oxidized_untracked)
      end
    end
  end

  private

  def update_untracked(list, source = "PuppetDB")
    list.each do |fqdn|
      unless Machine.unscoped.find_by_fqdn(fqdn)
        begin
          m = Machine.new(fqdn: fqdn)
          m.owner = Owner.default_owner
          m.save!
          VersionChangeWorker.perform_async(m.versions.last.id, source)
          MachineUpdateWorker.perform_async(m.fqdn)
        rescue ActiveRecord::RecordInvalid => e
          # just carry on, nothing happened but a deleted machine conflicted with the new FQDN
          Rails.logger.info "Machine with #{fqdn} could not be created"
        rescue Exception => e
          Rails.logger.error e
        end
      end
    end
  end
end
