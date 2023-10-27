require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'KCloudReports API V3' do

  before :each do
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true

    @owner = FactoryBot.create(:owner, users: [FactoryBot.create(:user)])
    @machine = FactoryBot.create(:machine, owner: @owner)
    allow(User).to receive(:current).and_return(@owner.users.first)

    #FactoryBot.create :api_token, owner: @owner
    @api_token_r = FactoryBot.create :api_token_r, owner: @owner
    @api_token_w = FactoryBot.create :api_token_w, owner: @owner
    @api_token_pr = FactoryBot.create :api_token_pr, owner: @owner

    # prevent execution of VersionChangeWorker, depends on running sidekiq workers
    allow(VersionChangeWorker).to receive(:perform_async) do |arg|
      nil
    end
  end
  
  describe "API is switched off" do
    it 'should not allow access' do
      IDB.config.modules.api.v3_enabled = false

      api_get(action: "k_cloud_reports", token: @api_token_r, version:"3")
      expect(response.status).to eq(501)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"API disabled."})
    end
  end

  describe "POST /k_cloud_reports" do
    it 'does not create a cloud report because of invalid token' do
      expect(KCloudReport.all.size).to eq(0)
      payload = {
        "ip":"192.168.0.111",
        "raw_data":"some JSON"
      }
      api_post_json_no_auth(action: "k_cloud_reports", payload: payload, version: "3")
      expect(response.status).to eq(401)
      expect(KCloudReport.all.size).to eq(0)
    end
  end

  describe "POST /k_cloud_reports" do
    it 'creates a cloud report' do
      expect(KCloudReport.all.size).to eq(0)
      payload = {
        "ip":"192.168.0.111",
        "raw_data":"some JSON"
      }
      api_post_json(action: "k_cloud_reports", token: @api_token_pr, payload: payload, version: "3")
      expect(response.status).to eq(201)
      expect(KCloudReport.all.size).to eq(1)
    end
  end
end
