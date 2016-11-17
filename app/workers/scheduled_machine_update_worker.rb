class ScheduledMachineUpdateWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(10) }

  def perform
    IDB.config.puppetdb.api_urls.each do |url|
      api = Puppetdb::Api.new(url["url"])
      namefield = "name"

      if url["version"] == "v3"
        nodes = api.get("/v3/nodes").data
      elsif url["version"] == "v4"
        nodes = api.get("/pdb/query/v4/nodes").data
        namefield = "certname"
      end

      if nodes
        nodes.each do |node|
          MachineUpdateWorker.perform_async(node[namefield], url["url"], url["version"])
        end
      end
    end
  end
end
