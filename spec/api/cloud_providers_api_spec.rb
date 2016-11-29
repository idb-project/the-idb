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

      api_get "cloud_providers", @api_token_r
      expect(response.status).to eq(501)
      expect(JSON.parse(response.body)).to eq({})
    end
  end

  describe "GET /cloud_providers" do
    it "returns error with invalid token" do
      api_get "cloud_providers", @api_token

      cloud_providers = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(cloud_providers["response_type"]).to eq("error")
      expect(cloud_providers["response"]).to eq("Unauthorized.")
    end

    it "returns all cloud providers if owner is not specified" do
      api_get "cloud_providers", @api_token_r

      cloud_providers = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(cloud_providers.size).to eq(2)
      expect(cloud_providers.first["name"]).to eq(@cloud_provider.name)
    end

    it "returns the cloud providers of an owner if owner is specified" do
      api_get "cloud_providers?owner=#{@user.id}", @api_token_r

      cloud_providers = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(cloud_providers.size).to eq(1)
      expect(cloud_providers.first["name"]).to eq(@cloud_provider.name)
    end

    it "returns a 404 if no cloud provider is found" do
      api_get "cloud_providers?owner=99999", @api_token_r

      cloud_providers = JSON.parse(response.body)
      expect(response.status).to eq(404)
      expect(cloud_providers.size).to eq(0)
    end
  end
end

