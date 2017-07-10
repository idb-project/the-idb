require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Location API V3' do

  before :each do
    IDB.config.modules.api.v1_enabled = false
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true

    @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)

    FactoryGirl.create :location, owner: @owner
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

      api_get(action: "locations", token: @api_token_r, version:"3")
      expect(response.status).to eq(501)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"API disabled."})
    end
  end

  describe "GET /locations but unauthorized" do
    it 'should return json error message' do
      api_get_unauthorized(action: "locations", version: "3")

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"Unauthorized."})
    end
  end

  describe "GET /locations" do
    it 'should return all locations' do
      api_get_auth_header(action: "locations", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      locations = JSON.parse(response.body)
      expect(locations.size).to eq(1)
      expect(locations[0]['name']).to eq(Location.last.name)
    end
  end

  describe "GET /locations?name=" do
    it 'should filter locations' do
      api_get(action: "locations?name=#{Location.last.name}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      location = JSON.parse(response.body)
      expect(location.size).to eq(1)
      expect(location[0]['name']).to eq(Location.last.name)
    end

    it 'should return empty JSON array if no item matches' do
      api_get(action: "locations?name=not_existing", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      locations = JSON.parse(response.body)
      expect(locations).to eq([])
    end
  end

  describe "GET /locations/id/{id}" do
    it 'should return a location by id' do
      api_get(action: "locations/id/#{Location.last.id}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      location = JSON.parse(response.body)
      expect(location['name']).to eq(Location.last.name)
    end
  end

  describe "GET /locations/roots" do
    it 'should return all root locations' do
      api_get(action: "locations/roots", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      locations = JSON.parse(response.body)
      expect(locations.size).to eq(1)
      expect(locations[0]["name"]).to eq(Location.last.name)
    end
  end

  describe "POST /locations/roots" do
    it 'creates a root location' do
      payload = {
        "name":"foobar"
      }
      api_post_json(action: "locations/roots", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      location = JSON.parse(response.body)
      expect(location['name']).to eq("foobar")
    end
  end

  describe "GET with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      api_get(action: "locations", token: @api_token, version: "3")
      expect(response.status).to eq(401)
    end
  end

  describe "POST with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      payload = {
        "name":"foobar"
      }
      api_post_json(action: "locations", token: @api_token, payload: payload, version: "3")
      expect(response.status).to eq(401)
    end
  end
end

