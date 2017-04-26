require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Cloud providers API' do

  before :each do
    IDB.config.modules.api.v2_enabled = true
    @user = FactoryGirl.create :owner
    @cloud_provider = FactoryGirl.create :cloud_provider, owner: @user
    @cloud_provider_no_owner = FactoryGirl.create :cloud_provider
    @api_token = FactoryGirl.create :api_token
    @api_token_r = FactoryGirl.create :api_token_r
  end

  describe "API is switched off" do
    it 'should not allow access' do
      IDB.config.modules.api.v2_enabled = false

      api_get(action: "cloud_providers", token: @api_token_r)
      body = JSON.parse(response.body)
      expect(response.status).to eq(501)
      expect(body["response_type"]).to eq("error")
      expect(body["response"]).to eq("API disabled.")
    end
  end

  describe "GET /cloud_providers" do
    it "returns error with invalid token" do
      api_get(action: "cloud_providers", token: @api_token)

      machines = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(machines["response_type"]).to eq("error")
      expect(machines["response"]).to eq("Unauthorized.")
    end

    it "returns a cloud provider given an id" do
      api_get( action: "cloud_providers?id=#{@cloud_provider.id}", token: @api_token_r)

      cloud_providers = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(cloud_providers["id"]).to eq(@cloud_provider.id)
    end

    it "returns the cloud provider given an name" do
      api_get( action: "cloud_providers?name=#{@cloud_provider.name}", token: @api_token_r)

      cloud_providers = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(cloud_providers.size).to eq(1)
      expect(cloud_providers.first["name"]).to eq(@cloud_provider.name)
    end

    it "returns the cloud provider given an name" do
      api_get(action: "cloud_providers?owner=#{@user.id}", token: @api_token_r)

      cloud_providers = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(cloud_providers.size).to eq(1)
      expect(cloud_providers.first["name"]).to eq(@cloud_provider.name)
    end

    it "returns all cloud_providers with no parameter" do
      api_get( action: "cloud_providers", token: @api_token_r)

      cloud_providers = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(cloud_providers.size).to eq(2)
    end
  end
end

