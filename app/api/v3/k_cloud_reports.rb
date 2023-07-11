module V3
  class KCloudReports < Grape::API
    helpers V3::Helpers

    version 'v3'
    format :json

    resource :k_cloud_reports do
      before do
        api_enabled!
        authenticate!
      end

      desc 'Create a new KCloudReport',
        params: KCloudReport::Entity.documentation,
        success: String
      post do
        token = can_post_reports!
        data_hash = params
        machine = nil
        kcr = KCloudReport.new(raw_data: params)
        kcr.ip = get_ip

        if kcr.ip
          ip = IpAddress.find_by_addr(kcr.ip)
          if ip
            kcr.machine = ip.machine if ip.machine
          end
        end

        unless data_hash.empty?
          if data_hash['software'] && data_hash['software']['reporter']
            kcr.reporter = data_hash['reporter']
          end
          if data_hash['license'] && data_hash['license']['dnsNames']
            data_hash['license']['dnsNames'].each do |dns_name|
              machine = Machine.find_by(fqdn: dns_name)
              unless machine
                m_alias = MachineAlias.find_by(name: dns_name)
                machine = m_alias.machine if m_alias
              end
            end
            kcr.machine = machine
          end
        end

        begin
          kcr.save!
          { :response_type => 'success', :response => "success" }.to_json
        rescue
          { :response_type => 'error', :response => "error saving cloud report" }.to_json
        end
      end
    end
  end
end
