class MachineUpdateWorker
  include Sidekiq::Worker

  def perform(name, url=nil, version=nil)
    # all urls to query
    urls = []

    # currently the IDB does not know if and in which puppetDB the machine exists
    # query all configured puppetDBs v3
    v3_urls = IDB.config.puppetdb.api_urls.map { |u| [u["url"]] if u["version"] == "v3" }.flatten.compact
    nodes = Puppetdb::Nodes.new(v3_urls)
    nodes.find_node(name) do |url|
      if url
        urls << {url: url, version: "v3"}
      end
    end

    # query all configured puppetDBs v4
    v4_urls = IDB.config.puppetdb.api_urls.map { |u| [u["url"]] if u["version"] == "v4" }.flatten.compact
    nodes = Puppetdb::NodesV4.new(v4_urls)
    nodes.find_node(name) do |url|
      if url
        urls << {url: url, version: "v4"}
      end
    end

    # query all configured oxidized APIs
    oxidized_urls = IDB.config.oxidized.api_urls.map { |u| [u["url"]] }.flatten.compact
    nodes = Oxidized::Nodes.new(oxidized_urls)
    nodes.find_node(name) do |url|
      if url
        urls << {url: url, version: "oxidized"}
      end
    end

    return if urls.empty? # machine was not found in any configured puppetDB

    machine = Machine.find_by_fqdn(name)
    if machine
      logger.info { "Update machine ##{machine.id}<#{machine.name}>" }
      urls.each do |url|
        if url[:version] == "oxidized"
          MachineUpdateService.update_from_oxidized_facts(machine, url[:url])
        else
          MachineUpdateService.update_from_facts(machine, url[:url], url[:version])
        end
      end
    end
  rescue Puppetdb::Api::ConnectionError => e
    logger.error(e)
  end
end
