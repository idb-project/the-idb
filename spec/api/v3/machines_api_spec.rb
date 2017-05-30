require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Machines API V3' do

  before :each do
    IDB.config.modules.api.v1_enabled = false
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true
    FactoryGirl.create :machine
    FactoryGirl.create :owner
    FactoryGirl.create :api_token
    @api_token = FactoryGirl.build :api_token
    @api_token_r = FactoryGirl.create :api_token_r
    @api_token_w = FactoryGirl.create :api_token_w

    # prevent execution of VersionChangeWorker, depends on running sidekiq workers
    allow(VersionChangeWorker).to receive(:perform_async) do |arg|
      nil
    end
  end
  
  describe "API is switched off" do
    it 'should not allow access' do
      IDB.config.modules.api.v1_enabled = false
      IDB.config.modules.api.v2_enabled = false
      IDB.config.modules.api.v3_enabled = false

      api_get(action: "machines", token: @api_token_r, version: "3")
      expect(response.status).to eq(501)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"API disabled."})
    end
  end

  describe "GET /machines but unauthorized" do
    it 'should return json error message' do
      api_get_unauthorized(action: "machines", version: "3")
      expect(response.status).to eq(401)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"Unauthorized."})
    end
  end

  describe "GET /machines" do
    it 'should return all machines' do
      api_get(action: "machines", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      expect(machines.size).to eq(1)
      expect(machines[0]['fqdn']).to eq(Machine.last.fqdn)
    end
  end

  describe "GET /machines with header authorization" do
    it 'should return all machines' do
      api_get_auth_header(action: "machines", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      expect(machines.size).to eq(1)
      expect(machines[0]['fqdn']).to eq(Machine.last.fqdn)
    end
  end

  describe "GET /machines?fqdn=" do
    it 'should return the corresponding machine' do
      api_get(action: "machines?fqdn=#{Machine.last.fqdn}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      expect(machines.size).to eq(1)
      expect(machines[0]['fqdn']).to eq(Machine.last.fqdn)
    end

    it 'should return empty JSON and code 404 if machine not found' do
      api_get(action: "machines?fqdn=does.not.exist", token: @api_token_r, version: "3")
      expect(response.status).to eq(404)

      machines = JSON.parse(response.body)
      expect(machines).to eq({"response_type" => "error", "response" => "Not Found"})
    end
  end

  describe "POST /machines" do
    it 'does not create a machine if fqdn is invalid' do
      api_get(action: "machines?fqdn=new-machine", token: @api_token_r, version: "3")
      machines = JSON.parse(response.body)
      expect(machines).to eq({"response_type" => "error", "response" => "Not Found"})

      payload = {
        "fqdn":"new-machine",
        "ucs_role":"master",
        "create_machine":true
      }
      api_post_json(action: "machines", token: @api_token_w, payload: payload, version: "3")

      expect(response.status).to eq(409)

      machine = JSON.parse(response.body)
      expect(machine).to eq({"response_type" => "error", "response" => "Invalid Machine"})
    end

    it 'creates a machine if not existing' do
      api_get(action: "machines?fqdn=new-machine.example.com", token: @api_token_r, version: "3")
      machines = JSON.parse(response.body)
      expect(machines).to eq({"response_type" => "error", "response" => "Not Found"})

      payload = {
        "fqdn":"new-machine.example.com",
        "ucs_role":"master"
      }

      api_post_json(action: "machines", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("new-machine.example.com")
      expect(machine['ucs_role']).to eq("master")
    end

    it 'creates a machine if not existing, entering the API token name into the history' do
      api_get(action: "machines?fqdn=new-machine.example.com", token: @api_token_r, version: "3")
      machines = JSON.parse(response.body)
      expect(machines).to eq({"response_type" => "error", "response" => "Not Found"})

      payload = {
        "fqdn":"new-machine.example.com",
        "ucs_role":"master"
      }

      api_post_json(action: "machines", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      machine = JSON.parse(response.body)
      expect(Machine.last.versions.last.whodunnit).to eq(@api_token_w.token)
    end

    it 'creates a machine with a software configuration if not existing' do
      api_get(action: "machines?fqdn=new-machine.example.com", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(response.status).to eq(404)

      payload = {
        "fqdn":"new-machine.example.com",
        "software": [{"name":"test1", "version":"1234"}, {"name":"test2", "version":"5678"}],
        "create_machine": true
      }
      api_post_json(action: "machines", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("new-machine.example.com")
      expect(machine['software'].size).to eq(2)
      expect(machine['software'][0]["name"]).to eq("test1")
      expect(machine['software'][0]["version"]).to eq("1234")
      expect(machine['software'][1]["name"]).to eq("test2")
      expect(machine['software'][1]["version"]).to eq("5678")
    end
  end

  describe "PUT /machines/fqdn" do
    it 'updates a machine if existing' do
      FactoryGirl.create(:machine, fqdn: "existing.example.com")

      api_get(action: "machines/existing.example.com", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")

      machine['ucs_role'] = "member"
      # remove nics and aliases because they can only be updated via nics subroute
      machine.delete('nics')
      machine.delete('aliases')

      api_put_json(action: "machines/existing.example.com", token: @api_token_w, payload: machine, version: "3")
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")
      expect(machine['ucs_role']).to eq("member")
    end

    it 'updates multiple attributes of a machine if existing' do
      FactoryGirl.create(:machine, fqdn: "existing2.example.com", cores: 3)

      api_get(action: "machines/existing2.example.com", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing2.example.com")

      machine['ucs_role'] = "member"
      machine['cores'] = 7

      # remove nics and aliases because they can only be updated via nics subroute
      machine.delete('nics')
      machine.delete('aliases')

      api_put_json(action: "machines/existing2.example.com", token: @api_token_w, payload: machine, version: "3")
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing2.example.com")
      expect(machine['ucs_role']).to eq("member")
      expect(machine['cores']).to eq(7)
    end

    it 'updates multiple attributes of a machine if existing, JSON payload' do
      FactoryGirl.create(:machine, fqdn: "existing3.example.com", cores: 3)

      api_get(action: "machines/existing3.example.com", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing3.example.com")

      payload = {
        "fqdn":"existing3.example.com",
        "backup_brand":"2",
        "backup_last_full_run":"2015-10-07 12:00:00"
      }
      
      api_put_json(action: "machines/existing3.example.com", token: @api_token_w, version: "3", payload: payload)
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing3.example.com")
      expect(machine['backup_brand']).to eq(2)

      api_get(action: "machines/existing3.example.com", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(machine['backup_brand']).to eq(2)
    end    

    it 'filters out not existing attributes' do
      FactoryGirl.create(:machine, fqdn: "existing3.example.com", cores: 3)

      api_get(action: "machines/existing3.example.com", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing3.example.com")


      payload = {
        "fqdn":"existing3.example.com",
        "zzz":"fhfhf"
      }

      api_put_json(action: "machines/existing3.example.com", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(200)
    end

    it 'updates the software of a machine if existing, JSON payload' do
      FactoryGirl.create(:machine, fqdn: "existing.example.com")

      api_get(action: "machines/existing.example.com", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")

      payload = {
        "software": [{"name":"test1", "version":"1234"}, {"name":"test2", "version":"5678"}]
      }
      api_put_json(action: "machines/existing.example.com", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")
      expect(machine['software'].size).to eq(2)
      expect(machine['software'][0]["name"]).to eq("test1")
      expect(machine['software'][0]["version"]).to eq("1234")
      expect(machine['software'][1]["name"]).to eq("test2")
      expect(machine['software'][1]["version"]).to eq("5678")
    end
  end

  describe "PUT /machines/fqdn on a deleted machine" do
    it 'returns 404' do
      fqdn = Machine.last.fqdn
      Machine.last.destroy!

      payload = {
        fqdn: fqdn
      }

      api_put_json(action: "machines/#{fqdn}", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(404)

      machine = JSON.parse(response.body)
      expect(machine).to eq({"response_type" => "error", "response" => "Not Found"})
    end
  end

  describe "GET with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      api_get(action: "machines", token: @api_token, version: "3")
      expect(response.status).to eq(401)
    end
  end

  describe "PUT with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      FactoryGirl.create(:machine, fqdn: "borken.example.com")

      payload = {
        "fqdn":"borken.example.com"
      }
      api_put_json(action: "machines/borken.example.com", token: @api_token, payload: payload, version: "3")
      expect(response.status).to eq(401)
    end
  end
end

