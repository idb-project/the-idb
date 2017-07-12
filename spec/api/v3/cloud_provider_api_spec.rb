require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Cloud Provider API V3' do

  before :each do
    IDB.config.modules.api.v1_enabled = false
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true

    @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)

    FactoryGirl.create :cloud_provider, owner: @owner
    FactoryGirl.create :api_token, owner: @owner
    @api_token = FactoryGirl.build :api_token, owner: @owner
    @api_token_r = FactoryGirl.create :api_token_r, owner: @owner
    @api_token_w = FactoryGirl.create :api_token_w, owner: @owner

    # prevent execution of VersionChangeWorker, depends on running sidekiq workers
    allow(VersionChangeWorker).to receive(:perform_async) do |arg|
      nil
    end
  end
  
  describe "API is switched off" do
    it 'should not allow access' do
      IDB.config.modules.api.v3_enabled = false

      api_get(action: "cloud_providers", token: @api_token_r, version:"3")
      expect(response.status).to eq(501)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"API disabled."})
    end
  end

  describe "GET /cloud_providers but unauthorized" do
    it 'should return json error message' do
      api_get_unauthorized(action: "cloud_providers", version: "3")

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"Unauthorized."})
    end
  end

  describe "GET /cloud_providers" do
    it 'should return all cloud provider configurations' do
      api_get(action: "cloud_providers", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      cloud_providers = JSON.parse(response.body)
      expect(cloud_providers.size).to eq(1)
      expect(cloud_providers[0]['name']).to eq(CloudProvider.last.name)
    end
  end

  describe "GET /cloud_providers with header authorization" do
    it 'should return all cloud provider configurations' do
      api_get_auth_header(action: "cloud_providers", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      cloud_providers = JSON.parse(response.body)
      expect(cloud_providers.size).to eq(1)
      expect(cloud_providers[0]['name']).to eq(CloudProvider.last.name)
    end
  end

  describe "GET /cloud_providers?fqdn=" do
    it 'should filter cloud provider items for items with this name' do
      api_get(action: "cloud_providers?name=#{CloudProvider.last.name}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      cloud_provider = JSON.parse(response.body)
      expect(cloud_provider.size).to eq(1)
      expect(cloud_provider[0]['name']).to eq(CloudProvider.last.name)
    end

    it 'should return empty JSON array and if no switch item matches' do
      api_get(action: "cloud_providers?name=not_existing", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      cloud_providers = JSON.parse(response.body)
      expect(cloud_providers).to eq([])
    end
  end

  describe "POST /cloud_providers" do
    it 'creates a cloud provider' do
      api_get(action: "cloud_providers/foobar", token: @api_token_r, version: "3")
      cloud_provider = JSON.parse(response.body)
      expect(cloud_provider).to eq("response_type"=>"error", "response"=>"Not found")

      payload = {
        "name":"foobar",
        "config": "config"
      }
      api_post_json(action: "cloud_providers", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      cloud_provider = JSON.parse(response.body)
      expect(cloud_provider['name']).to eq("foobar")
      expect(cloud_provider['config']).to eq("config")
    end
  end

  describe "GET with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      api_get(action: "cloud_providers", token: @api_token, version: "3")
      expect(response.status).to eq(401)
    end
  end

  describe "POST with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      payload = {
        "name":"foobar"
      }
      api_post_json(action: "cloud_providers", token: @api_token, payload: payload, version: "3")
      expect(response.status).to eq(401)
    end
  end
end

