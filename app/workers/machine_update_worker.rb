class MachineUpdateWorker
  include Sidekiq::Worker

  def perform(name, url=nil, version=nil)
    # currently the IDB does not know if and in which puppetDB the machine exists
    unless url
      # query all configured puppetDBs v3
      v3_urls = IDB.config.puppetdb.api_urls.map { |u| [u["url"]] if u["version"] == "v3" }.flatten.compact
      nodes = Puppetdb::Nodes.new(v3_urls)
      url = nodes.find_node(name)
      version = "v3" if url
    end

    unless url
      # query all configured puppetDBs v4
      v4_urls = IDB.config.puppetdb.api_urls.map { |u| [u["url"]] if u["version"] == "v4" }.flatten.compact
      nodes = Puppetdb::NodesV4.new(v4_urls)
      url = nodes.find_node(name)
      version = "v4" if url
    end

    unless url
      # query all configured oxidized APIs
      if IDB.config.oxidized # test if oxidized is configured, otherwise this throws
        oxidized_urls = IDB.config.oxidized.api_urls.map { |u| [u["url"]] }.flatten.compact
        nodes = Oxidized::Nodes.new(oxidized_urls)
        url = nodes.find_node(name)
        version = "oxidized" if url
      end
    end

    return unless url # machine was not found in any configured puppetDB

    machine = Machine.find_by_fqdn(name)
    if machine
      logger.info { "Update machine ##{machine.id}<#{machine.name}>" }
      if version == "oxidized"
        MachineUpdateService.update_from_oxidized_facts(machine, url)
      else
        MachineUpdateService.update_from_facts(machine, url, version)
      end
    end
  rescue Puppetdb::Api::ConnectionError => e
    logger.error(e)
  end
end
