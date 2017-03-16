require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Machines API' do

  before :each do
    IDB.config.modules.api.v1_enabled = true
    IDB.config.modules.api.v2_enabled = true
    FactoryGirl.create :machine
    FactoryGirl.create :owner
    FactoryGirl.create :api_token
    @api_token = FactoryGirl.build :api_token
    @api_token_r = FactoryGirl.create :api_token_r
    @api_token_w = FactoryGirl.create :api_token_w
    @api_token_w2 = FactoryGirl.create :api_token_w

    # prevent execution of VersionChangeWorker, depends on running sidekiq workers
    allow(VersionChangeWorker).to receive(:perform_async) do |arg|
      nil
    end
  end
  
  describe "API is switched off" do
    it 'should not allow access' do
      IDB.config.modules.api.v1_enabled = false
      IDB.config.modules.api.v2_enabled = false

      api_get "machines", @api_token_r
      expect(response.status).to eq(501)
      expect(JSON.parse(response.body)).to eq({})
    end
  end

  describe "GET /machines but unauthorized" do
    it 'should return json error message' do
      api_get_unauthorized "machines"
      expect(response.status).to eq(401)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"Unauthorized."})
    end
  end

  describe "GET /machines" do
    it 'should return all machines' do
      api_get "machines", @api_token_r
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      expect(machines.size).to eq(1)
      expect(machines[0]['fqdn']).to eq(Machine.last.fqdn)
    end
  end

  describe "GET /machines with header authorization" do
    it 'should return all machines' do
      api_get_auth_header "machines", @api_token_r
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      expect(machines.size).to eq(1)
      expect(machines[0]['fqdn']).to eq(Machine.last.fqdn)
    end
  end

  describe "GET /machines?fqdn=" do
    it 'should return the corresponding machine' do
      api_get "machines?fqdn=#{Machine.last.fqdn}", @api_token_r
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq(Machine.last.fqdn)
    end

    it 'should return empty JSON and code 404 if machine not found' do
      api_get "machines?fqdn=does.not.exist", @api_token_r
      expect(response.status).to eq(404)

      machines = JSON.parse(response.body)
      expect(machines).to eq({})
    end
  end

  describe "PUT /machines?fqdn=" do
    it 'does not create a machine if fqdn is invalid' do
      api_get "machines?fqdn=new-machine", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine).to eq({})

      api_put "machines?fqdn=new-machine&ucs_role=master&create_machine=true", @api_token_w
      expect(response.status).to eq(409)

      machine = JSON.parse(response.body)
      expect(machine).to eq({})
    end

    it 'creates a machine if not existing' do
      api_get "machines?fqdn=new-machine.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine).to eq({})

      api_put "machines?fqdn=new-machine.example.com&ucs_role=master&create_machine=true", @api_token_w
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("new-machine.example.com")
      expect(machine['ucs_role']).to eq("master")
    end

    it 'creates a machine if not existing, entering the API token name into the history' do
      api_get "machines?fqdn=new-machine.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine).to eq({})

      api_put "machines?fqdn=new-machine.example.com&ucs_role=master&create_machine=true", @api_token_w
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(Machine.last.versions.last.whodunnit).to eq(@api_token_w.name)
    end

    it 'does not create a machine if not explicitely specified' do
      api_get "machines?fqdn=new-machine.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine).to eq({})

      api_put "machines?fqdn=new-machine.example.com&ucs_role=master", @api_token_w
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine).to eq({})
    end

    it 'creates a machine if not existing, JSON payload' do
      api_get "machines?fqdn=new-machine2.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine).to eq({})

      payload = {
        "fqdn":"new-machine2.example.com",
        "ucs_role":"master",
        "create_machine":true
      }
      api_put_json "machines?fqdn=new-machine2.example.com&ucs_role=master", @api_token_w, payload
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("new-machine2.example.com")
      expect(machine['ucs_role']).to eq("master")
    end

    it 'updates a machine if existing' do
      FactoryGirl.create(:machine, fqdn: "existing.example.com")

      api_get "machines?fqdn=existing.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")

      api_put "machines?fqdn=existing.example.com&ucs_role=member", @api_token_w
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")
      expect(machine['ucs_role']).to eq("member")
    end

    it 'sets the API raw data on machine update' do
      FactoryGirl.create(:machine, fqdn: "existing.example.com")

      api_get "machines?fqdn=existing.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")

      # sets the raw api data
      api_put "machines?fqdn=existing.example.com&backup_brand=2", @api_token_w
      m = Machine.find_by_fqdn("existing.example.com")
      data = JSON.parse(m.raw_data_api)
      expect(data.keys.first).to eq(@api_token_w.name)
      expect(data[@api_token_w.name]["backup_brand"]).to eq("2")
    end

    it 'keeps the API raw data from different API token on machine update' do
      FactoryGirl.create(:machine, fqdn: "existing.example.com")

      api_get "machines?fqdn=existing.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")

      # sets the raw api data
      api_put "machines?fqdn=existing.example.com&backup_brand=2", @api_token_w
      api_put "machines?fqdn=existing.example.com&backup_brand=12&custom_attribute=test", @api_token_w2
      m = Machine.find_by_fqdn("existing.example.com")
      data = JSON.parse(m.raw_data_api)
      expect(data.keys.size).to eq(2)
      expect(data[@api_token_w.name]["backup_brand"]).to eq("2")
      expect(data[@api_token_w2.name]["custom_attribute"]).to eq("test")
      expect(data[@api_token_w2.name]["backup_brand"]).to eq("12")
    end

    it 'sets the backup_type if backup parameters are presented' do
      FactoryGirl.create(:machine, fqdn: "existing.example.com")

      api_get "machines?fqdn=existing.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")

      # set by backup_brand > 0
      api_put "machines?fqdn=existing.example.com&backup_brand=2", @api_token_w
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")
      expect(machine['backup_type']).to eq(1)

      # reset
      api_put "machines?fqdn=existing.example.com&backup_type=0", @api_token_w
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")
      expect(machine['backup_type']).to eq(0)

      # set by backup_last_inc_run != ""
      api_put "machines?fqdn=existing.example.com&backup_last_inc_run=19012016", @api_token_w
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")
      expect(machine['backup_type']).to eq(1)
    end

    it 'updates a machine if existing, JSON payload' do
      FactoryGirl.create(:machine, fqdn: "existing2.example.com")

      api_get "machines?fqdn=existing2.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing2.example.com")

      payload = {
        "fqdn":"existing2.example.com",
        "ucs_role":"masterslavemember"
      }
      api_put_json "machines?fqdn=existing2.example.com&ucs_role=member", @api_token_w, payload
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing2.example.com")
      expect(machine['ucs_role']).to eq("masterslavemember")
    end

    it 'returns a 404 if no fqdn was provided' do
      api_put "machines?cores=4", @api_token_w
      expect(response.status).to eq(400)
    end

    it 'updates multiple attributes of a machine if existing' do
      FactoryGirl.create(:machine, fqdn: "existing2.example.com", cores: 3)

      api_get "machines?fqdn=existing2.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing2.example.com")

      api_put "machines?fqdn=existing2.example.com&ucs_role=member&cores=7", @api_token_w
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing2.example.com")
      expect(machine['ucs_role']).to eq("member")
      expect(machine['cores']).to eq(7)
    end

    it 'updates multiple attributes of a machine if existing, JSON payload' do
      FactoryGirl.create(:machine, fqdn: "existing3.example.com", cores: 3)

      api_get "machines?fqdn=existing3.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing3.example.com")

      payload = {
        "fqdn":"existing3.example.com",
        "backup_brand":"2",
        "backup_last_full_run":"2015-10-07 12:00:00"
      }
      
      api_put_json "machines", @api_token_w, payload
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing3.example.com")
      expect(machine['backup_brand']).to eq(2)

      api_get "machines?fqdn=existing3.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['backup_brand']).to eq(2)
    end    

    it 'filters out not existing attributes' do
      FactoryGirl.create(:machine, fqdn: "existing3.example.com", cores: 3)

      api_get "machines?fqdn=existing3.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing3.example.com")

      api_put "machines?fqdn=existing3.example.com&zzz=fhfhf", @api_token_w
      expect(response.status).to eq(200)
    end

    it 'updates the software of a machine if existing, JSON payload' do
      FactoryGirl.create(:machine, fqdn: "existing.example.com")

      api_get "machines?fqdn=existing.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")

      payload = {
        "fqdn":"existing.example.com",
        "software": [{"name":"test1", "version":"1234"}, {"name":"test2", "version":"5678"}]
      }
      api_put_json "machines?fqdn=existing.example.com", @api_token_w, payload
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing.example.com")
      expect(machine['software'].size).to eq(2)
      expect(machine['software'][0]["name"]).to eq("test1")
      expect(machine['software'][0]["version"]).to eq("1234")
      expect(machine['software'][1]["name"]).to eq("test2")
      expect(machine['software'][1]["version"]).to eq("5678")
    end

    it 'creates a machine with a software configuration if not existing' do
      api_get "machines?fqdn=new-machine.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine).to eq({})

      payload = {
        "fqdn":"new-machine.example.com",
        "software": [{"name":"test1", "version":"1234"}, {"name":"test2", "version":"5678"}],
        "create_machine": true
      }
      api_put_json "machines?fqdn=new-machine.example.com", @api_token_w, payload
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("new-machine.example.com")
      expect(machine['software'].size).to eq(2)
      expect(machine['software'][0]["name"]).to eq("test1")
      expect(machine['software'][0]["version"]).to eq("1234")
      expect(machine['software'][1]["name"]).to eq("test2")
      expect(machine['software'][1]["version"]).to eq("5678")
    end
  end

  describe "PUT /machines with multiple machines" do
    it 'creates the machines if not existing' do
      api_get "machines?fqdn=new-machine-a.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine).to eq({})
      api_get "machines?fqdn=new-machine-b.example.com", @api_token_r
      machine = JSON.parse(response.body)
      expect(machine).to eq({})

      payload = {
        "create_machine":true,
        "machines":[{
          "fqdn":"new-machine-a.example.com",
          "cores":"3",
          "nics": [{
            "ip_address": {
              "addr": "192.168.5.5"
            },
            "name": "eth5",
            "mac": "3c:97:0e:d8:81:e7"
            }]
        },{
          "fqdn":"new-machine-b.example.com",
          "cores":"5"
        }]
      }
      api_put_json "machines", @api_token_w, payload

      machines = JSON.parse(response.body)
      expect(machines.size).to eq(2)

      machines.each do |machine|
        if machine['fqdn'] == "new-machine-a.example.com"
          expect(machine['cores']).to eq(3)
          expect(machine['owner_id']).not_to be_nil
        else
          expect(machine['cores']).to eq(5)
        end
      end

      m = Machine.find_by_fqdn("new-machine-a.example.com")
      expect(m).not_to be_nil
      expect(m.nics.size).to eq(1)
    end

    it 'updates the machines' do
      FactoryGirl.create(:machine, fqdn: "x.example.com", cores: 3)
      FactoryGirl.create(:machine, fqdn: "y.example.com", cores: 6)

      payload = {
        "machines":[{
          "fqdn":"x.example.com",
          "cores":"2",
          "ram":"1024"
        },{
          "fqdn":"y.example.com",
          "cores":"5",
          "ram":"2048"
        }]
      }
      api_put_json "machines", @api_token_w, payload

      machines = JSON.parse(response.body)
      expect(machines.size).to eq(2)

      machines.each do |machine|
        if machine['fqdn'] == "x.example.com"
          expect(machine['cores']).to eq(2)
          expect(machine['ram']).to eq(1024)
        else
          expect(machine['cores']).to eq(5)
          expect(machine['ram']).to eq(2048)
        end
      end
    end
  end

  describe "PUT /machines?fqdn= on a deleted machine" do
    it 'returns empty list and a 200 code without create_machine set' do
      fqdn = Machine.last.fqdn
      Machine.last.destroy!

      api_put "machines?fqdn=#{fqdn}&ucs_role=master", @api_token_w
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine).to eq({})
    end

    it 'returns empty list and a 409 code with create_machine set' do
      fqdn = Machine.last.fqdn
      Machine.last.destroy!

      api_put "machines?fqdn=#{fqdn}&ucs_role=master&create_machine=true", @api_token_w
      expect(response.status).to eq(409)

      machine = JSON.parse(response.body)
      expect(machine).to eq({})
    end
  end

  describe "GET with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      api_get "machines", @api_token
      expect(response.status).to eq(401)
    end
  end

  describe "PUT with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      api_put "machines?fqdn=borken.example.com&create_machine=true", @api_token
      expect(response.status).to eq(401)
    end
  end
end

