require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Maintenance Records API V3' do

  before :each do
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true

    @owner = FactoryBot.create(:owner, users: [FactoryBot.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)

    @machine = FactoryBot.create :machine, fqdn: "test.example.com", owner: @owner
    @mr = FactoryBot.create :maintenance_record, machine: @machine, created_at: "2017-01-01 00:00:00"
    FactoryBot.create :api_token, owner: @owner
    @api_token = FactoryBot.build :api_token, owner: @owner
    @api_token_r = FactoryBot.create :api_token_r, owner: @owner
    @api_token_w = FactoryBot.create :api_token_w, owner: @owner
    @api_token_pl = FactoryBot.create :api_token_pl, owner: @owner

    # prevent execution of VersionChangeWorker, depends on running sidekiq workers
    allow(VersionChangeWorker).to receive(:perform_async) do |arg|
      nil
    end
  end
  
  describe "GET /maintenance_records" do
    it 'should return all maintenance records' do
      api_get(action: "maintenance_records", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      mrs = JSON.parse(response.body)
      expect(mrs.size).to eq(1)
      expect(mrs[0]['machine']).to eq(@machine.fqdn)
    end

    it 'should return all maintenance records for multiple tokens' do
      user = FactoryBot.create(:user)
      owner_1 = FactoryBot.create(:owner, users: [user])
      owner_2 = FactoryBot.create(:owner, users: [user])
      token_1 = FactoryBot.create :api_token_r, owner: owner_1, name: "FOOBARTOKEN1"
      token_2 = FactoryBot.create :api_token_r, owner: owner_2, name: "FOOBARTOKEN2"
      allow(User).to receive(:current).and_return(owner_1.users.first)
      allow(User).to receive(:current).and_return(owner_2.users.first)

      m1 = FactoryBot.create :machine, owner: owner_1
      mr1 = FactoryBot.create :maintenance_record, machine: m1, created_at: "2017-01-01 00:00:00"
      m2 = FactoryBot.create :machine, owner: owner_2
      mr2 = FactoryBot.create :maintenance_record, machine: m2, created_at: "2017-01-01 00:00:00"

      get "/api/v3/maintenance_records", headers: {'X-IDB-API-Token': "#{token_1.token}, #{token_2.token}" }
      expect(response.status).to eq(200)

      mrs = JSON.parse(response.body)
      expect(mrs.size).to eq(2)
      expect(mrs[0]['machine']).to eq(m1.fqdn)
      expect(mrs[1]['machine']).to eq(m2.fqdn)
    end
  end

  describe "GET /maintenance_records?fqdn=" do
    it 'should filter records by fqdn' do
      api_get(action: "maintenance_records?machine=#{@machine.fqdn}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      mrs = JSON.parse(response.body)
      expect(mrs.size).to eq(1)
      expect(mrs[0]['machine']).to eq(@machine.fqdn)
    end

    it 'should return empty JSON array and if no maintenance record matches' do
      api_get(action: "maintenance_records?machine=aa.bb.cc", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      expect(machines).to eq([])
    end
  end

  describe "GET /maintenance_records/{fqdn}" do
    it 'should return all maintenance records for a specific machine' do
      api_get(action: "maintenance_records/#{@machine.fqdn}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      mrs = JSON.parse(response.body)
      expect(mrs.size).to eq(1)
      expect(mrs[0]['machine']).to eq(@machine.fqdn)
    end
  end

  describe "GET /maintenance_records/{fqdn}/{timestamp}" do
    it 'should return a single maintenance record of a machine' do
      api_get(action: "maintenance_records/#{@machine.fqdn}/#{@mr.created_at.iso8601.to_s}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      mr = JSON.parse(response.body)
      expect(mr['machine']).to eq(@machine.fqdn)
    end
  end

  describe "POST /maintenance_records" do
    it 'should create a new maintenance record' do
      payload = {
        "machine": @machine.fqdn,
        "logfile": "test test test",
        "user": @owner.users.first.login
      }
      api_post_json(action: "maintenance_records", token: @api_token_pl, version: "3", payload: payload)
      expect(response.status).to eq(201)
      mr = JSON.parse(response.body)
      expect(mr["machine"]).to eq(@machine.fqdn)
      expect(mr["logfile"]).to eq("test test test")
      expect(mr["user"]).to eq(@owner.users.first.login)
    end
  end

  describe "GET /maintenance_records/{fqdn}/{timestamp}/attachments" do
    it "shows all attachments" do
      FactoryBot.create(:attachment, maintenance_record: @mr, owner: @owner)
      FactoryBot.create(:attachment, maintenance_record: @mr, owner: @owner)

      api_get(action: "/maintenance_records/#{@machine.fqdn}/#{@mr.created_at.iso8601.to_s}/attachments", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      attachments = JSON.parse(response.body)
      expect(attachments.size).to eq(2)
    end
  end
end

