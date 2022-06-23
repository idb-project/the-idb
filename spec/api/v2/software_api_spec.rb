require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Software API' do

  before :each do
    IDB.config.modules.api.v2_enabled = true
    owner = FactoryBot.create(:owner, users: [FactoryBot.create(:user)])
    allow(User).to receive(:current).and_return(owner.users.first)
    @api_token = FactoryBot.create :api_token
    @api_token_r = FactoryBot.create :api_token_r
    create(:machine, owner: owner, software: [{name: "ruby", version: "2.2.5"}, {name: "nginx", version: "1.10.1"}])
    create(:machine, owner: owner, software: [{name: "nginx", version: "1.10.1-0ubuntu1.2"}])
  end

  describe "API is switched off" do
    it 'should not allow access' do
      IDB.config.modules.api.v2_enabled = false

      api_get(action: "software", token: @api_token_r)
      body = JSON.parse(response.body)
      expect(response.status).to eq(501)
      expect(body["response_type"]).to eq("error")
      expect(body["response"]).to eq("API disabled.")
    end
  end

  describe "GET /software" do
    it "returns error with invalid token" do
      api_get(action: "software", token: @api_token)

      machines = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(machines["response_type"]).to eq("error")
      expect(machines["response"]).to eq("Unauthorized.")
    end

    it "returns an empty array for a empty query" do
      api_get(action: "software?package=", token: @api_token_r)

      machines = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(machines.size).to eq(0)
    end

    it "returns all machines matching the search parameters, name only" do
      api_get(action: "software?package=nginx", token: @api_token_r)

      machines = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(machines.size).to eq(2)

      api_get(action: "software?package=ruby", token: @api_token_r)

      machines = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(machines.size).to eq(1)
    end
  end
end


