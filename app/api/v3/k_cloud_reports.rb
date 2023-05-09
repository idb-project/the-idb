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
        #can_write!
        kcr = KCloudReport.new(raw_data: params)
        kcr.save!
        { :response_type => 'success', :response => "success" }.to_json
      end
    end
  end
end
