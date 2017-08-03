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
end

