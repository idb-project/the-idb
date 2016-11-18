class MachineFinderService
  def initialize(redis)
    @list = UntrackedMachinesList.new(redis)

    v3_urls = IDB.config.puppetdb.api_urls.map { |u| [u["url"]] if u["version"] == "v3" }.flatten.compact
    @nodes = Puppetdb::Nodes.new(v3_urls).all

    v4_urls = IDB.config.puppetdb.api_urls.map { |u| [u["url"]] if u["version"] == "v4" }.flatten.compact
    @nodes += Puppetdb::NodesV4.new(v4_urls).all
  end

  def find_untracked_machines
    nodes = @nodes
    machines = Machine.pluck(:fqdn)
    machine_aliases = MachineAlias.pluck(:name)
    untracked = nodes - machines - machine_aliases

    if IDB.config.puppetdb.auto_create
      untracked.each do |fqdn|
        unless Machine.unscoped.find_by_fqdn(fqdn)
          begin
            m = Machine.new(fqdn: fqdn)
            m.owner = Owner.first
            m.save!
            VersionChangeWorker.perform_async(m.versions.last.id, "PuppetDB")
            MachineUpdateWorker.perform_async(m.fqdn)
          rescue ActiveRecord::RecordInvalid => e
            # just carry on, nothing happened but a deleted machine conflicted with the new FQDN
            Rails.logger.info "Machine with #{fqdn} could not be created"
          rescue Exception => e
            Rails.logger.error e
          end
        end
      end
    else
      # Add all nodes that are not in the database to the untracked machines
      # list.
      @list.set(untracked)
    end
  end
end
