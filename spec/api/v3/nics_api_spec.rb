require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Nics API V3' do

  before :each do
    IDB.config.modules.api.v1_enabled = false
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true

    @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)

    FactoryGirl.create :api_token, owner: @owner
    @api_token = FactoryGirl.build :api_token, owner: @owner
    @api_token_r = FactoryGirl.create :api_token_r, owner: @owner
    @api_token_w = FactoryGirl.create :api_token_w, owner: @owner

    # prevent execution of VersionChangeWorker, depends on running sidekiq workers
    allow(VersionChangeWorker).to receive(:perform_async) do |arg|
      nil
    end
  end
  
  describe "GET /nics but unauthorized" do
    it 'should return json error message' do
      api_get_unauthorized(action: "nics", version: "3")

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"Unauthorized."})
    end
  end

  describe "GET /nics" do
    it 'should return all nics' do
      wrong_owner = FactoryGirl.create :owner
      wrong_machine = FactoryGirl.create :machine, owner: wrong_owner
      wrong_nic = FactoryGirl.create :nic, machine: wrong_machine

      m = FactoryGirl.create :machine, owner: @owner
      FactoryGirl.create :nic, machine: m

      api_get(action: "nics", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      nics = JSON.parse(response.body)
      expect(nics.size).to eq(1)
    end
  end

  describe "GET /nics" do
    it 'should return all nics for multiple owners' do
      user = FactoryGirl.create(:user)
      owner_1 = FactoryGirl.create(:owner, users: [user])
      owner_2 = FactoryGirl.create(:owner, users: [user])
      token_1 = FactoryGirl.create :api_token_r, owner: owner_1, name: "FOOBARTOKEN1"
      token_2 = FactoryGirl.create :api_token_r, owner: owner_2, name: "FOOBARTOKEN2"
      allow(User).to receive(:current).and_return(owner_1.users.first)
      allow(User).to receive(:current).and_return(owner_2.users.first)

      m1 = FactoryGirl.create :machine, owner: owner_1
      n1 = FactoryGirl.create :nic, machine: m1
      m2 = FactoryGirl.create :machine, owner: owner_2
      n2 = FactoryGirl.create :nic, machine: m2

      get "/api/v3/nics", headers: {'X-IDB-API-Token': "#{token_1.token}, #{token_2.token}" }
      expect(response.status).to eq(200)

      nics = JSON.parse(response.body)
      expect(nics.size).to eq(2)

      expect(nics[0]["machine"]).to eq(m1.fqdn)
      expect(nics[1]["machine"]).to eq(m2.fqdn)
    end
  end
end

