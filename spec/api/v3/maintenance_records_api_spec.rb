require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Maintenance Records API V3' do

  before :each do
    IDB.config.modules.api.v1_enabled = false
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true

    @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)

    @machine = FactoryGirl.create :machine, fqdn: "test.example.com", owner: @owner
    @mr = FactoryGirl.create :maintenance_record, machine: @machine, created_at: "2017-01-01 00:00:00"
    FactoryGirl.create :api_token, owner: @owner
    @api_token = FactoryGirl.build :api_token, owner: @owner
    @api_token_r = FactoryGirl.create :api_token_r, owner: @owner
    @api_token_w = FactoryGirl.create :api_token_w, owner: @owner

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
      api_get(action: "maintenance_records/#{@machine.fqdn}/#{@mr.created_at.iso8601}", token: @api_token_r, version: "3")
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
      api_post_json(action: "maintenance_records", token: @api_token_w, version: "3", payload: payload)
      expect(response.status).to eq(201)
      mr = JSON.parse(response.body)
      expect(mr["machine"]).to eq(@machine.fqdn)
      expect(mr["logfile"]).to eq("test test test")
      expect(mr["user"]).to eq(@owner.users.first.login)
    end
  end

  describe "GET /maintenance_records/{fqdn}/{timestamp}/attachments" do
    it "shows all attachments" do
      FactoryGirl.create(:attachment, maintenance_record: @mr, owner: @owner)
      FactoryGirl.create(:attachment, maintenance_record: @mr, owner: @owner)

      api_get(action: "/maintenance_records/#{@machine.fqdn}/#{@mr.created_at.iso8601.to_s}/attachments", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      attachments = JSON.parse(response.body)
      expect(attachments.size).to eq(2)
    end
  end
end

