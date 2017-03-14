require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Software API' do

  before :each do
    IDB.config.modules.api.v2_enabled = true
    @api_token = FactoryGirl.create :api_token
    @api_token_r = FactoryGirl.create :api_token_r
    create(:machine, software: [{name: "ruby", version: "2.2.5"}, {name: "nginx", version: "1.10.1"}])
    create(:machine, software: [{name: "nginx", version: "1.10.1-0ubuntu1.2"}])
  end

  describe "API is switched off" do
    it 'should not allow access' do
      IDB.config.modules.api.v2_enabled = false

      api_get "software", @api_token_r
      body = JSON.parse(response.body)
      expect(response.status).to eq(501)
      expect(body["response_type"]).to eq("error")
      expect(body["response"]).to eq("API disabled.")
    end
  end

  describe "GET /software" do
    it "returns error with invalid token" do
      api_get "software", @api_token

      machines = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(machines["response_type"]).to eq("error")
      expect(machines["response"]).to eq("Unauthorized.")
    end

    it "returns an empty array for a empty query" do
      api_get "software?q=", @api_token_r

      machines = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(machines.size).to eq(0)
    end

    it "returns all machines matching the search parameters, name only" do
      api_get "software?q=nginx", @api_token_r

      machines = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(machines.size).to eq(2)

      api_get "software?q=ruby", @api_token_r

      machines = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(machines.size).to eq(1)
    end
  end
end


