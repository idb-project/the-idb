require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Switches API V3' do

  before :each do
    IDB.config.modules.api.v1_enabled = false
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true
    FactoryGirl.create :switch
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
      IDB.config.modules.api.v3_enabled = false

      api_get(action: "switches", token: @api_token_r, version:"3")
      expect(response.status).to eq(501)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"API disabled."})
    end
  end

  describe "GET /switches but unauthorized" do
    it 'should return json error message' do
      api_get_unauthorized(action: "switches", version: "3")

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"Unauthorized."})
    end
  end

  describe "GET /switches" do
    it 'should return all switches' do
      api_get(action: "switches", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      switches = JSON.parse(response.body)
      expect(switches.size).to eq(1)
      expect(switches[0]['fqdn']).to eq(Switch.last.fqdn)
    end
  end

  describe "GET /switches with header authorization" do
    it 'should return all switches' do
      api_get_auth_header(action: "switches", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      switches = JSON.parse(response.body)
      expect(switches.size).to eq(1)
      expect(switches[0]['fqdn']).to eq(Switch.last.fqdn)
    end
  end

  describe "GET /switch?fqdn=" do
    it 'should filter switch items for items with this fqdn' do
      api_get(action: "switches?fqdn=#{Switch.last.fqdn}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      switch = JSON.parse(response.body)
      expect(switch.size).to eq(1)
      expect(switch[0]['fqdn']).to eq(Switch.last.fqdn)
    end

    it 'should return empty JSON array and if no switch item matches' do
      api_get(action: "switches?fqdn=nonexisting_switch", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      switches = JSON.parse(response.body)
      expect(switches).to eq([])
    end
  end

  describe "POST /switches" do
    it 'creates a switch' do
      api_get(action: "switches/switch.example.org", token: @api_token_r, version: "3")
      switch = JSON.parse(response.body)
      expect(switch).to eq("response_type"=>"error", "response"=>"Not found")

      payload = {
        "fqdn":"switch.example.org"
      }
      api_post_json(action: "switches", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      switch = JSON.parse(response.body)
      expect(switch['fqdn']).to eq("switch.example.org")
    end

    it 'creates switch if not existing, entering the API token name into the history' do
      api_get(action: "switches/switch.example.org", token: @api_token_r, version: "3")
      switch = JSON.parse(response.body)
      expect(switch).to eq("response_type"=>"error", "response"=>"Not found")

      payload = {
        "fqdn":"switch.example.org"
      }
      api_post_json(action: "switches", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      switch = JSON.parse(response.body)
      expect(Switch.last.versions.last.whodunnit).to eq(@api_token_w.token)
    end
  end

  describe "GET /switches/{fqdn}/ports" do
    it "gets all switch ports" do
      s = FactoryGirl.create(:switch, fqdn: "switch.example.org")
      FactoryGirl.create(:switch_port, switch: s, nic: FactoryGirl.create(:nic), number: 1)
      FactoryGirl.create(:switch_port, switch: s, nic: FactoryGirl.create(:nic), number: 2)

      api_get(action: "switches/switch.example.org/ports", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)
      switch_ports = JSON.parse(response.body)
      expect(switch_ports.size).to eq(2)
      expect(switch_ports[1]["number"]).to eq(SwitchPort.last.number)
    end
  end

  describe "POST /switches/{fqdn}/ports" do
    it "creates a new switch port" do
      s = FactoryGirl.create(:switch, fqdn: "switch.example.org")
      m = FactoryGirl.create(:machine)
      n = FactoryGirl.create(:nic, machine: m)

      payload = {
        "number":1,"nic": n.name, "machine": m.fqdn, "switch":"switch.example.org"
      }
      api_post_json(action: "switches/switch.example.org/ports", token: @api_token_w, version: 3, payload: payload)
      expect(response.status).to eq(201)
      switch_port = JSON.parse(response.body)
      expect(switch_port["number"]).to eq(1)
      expect(switch_port["nic"]).to eq(Nic.last.name)
      expect(switch_port["machine"]).to eq(Machine.last.fqdn)
      expect(switch_port["switch"]).to eq(Switch.last.fqdn)
    end
  end

  describe "PUT /switches/{fqdn}/ports/{number}" do
    it "updates a switch port" do
      s = FactoryGirl.create(:switch, fqdn: "switch.example.org")
      m = FactoryGirl.create(:machine)
      n1 = FactoryGirl.create(:nic, machine: m)
      n2 = FactoryGirl.create(:nic, machine: m)
      p = FactoryGirl.create(:switch_port, number: 1, nic: n1, switch: s)

      payload = {
        "number":1,"nic": n2.name, "machine": m.fqdn
      }
      api_put_json(action: "switches/switch.example.org/ports/1", token: @api_token_w, version: 3, payload: payload)
      puts(response.body)
      expect(response.status).to eq(201)
      switch_port = JSON.parse(response.body)
      expect(switch_port["number"]).to eq(1)
      expect(switch_port["nic"]).to eq(Nic.last.name)
      expect(switch_port["machine"]).to eq(Machine.last.fqdn)
      expect(switch_port["switch"]).to eq(Switch.last.fqdn)      
    end
  end

  describe "GET with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      api_get(action: "switches", token: @api_token, version: "3")
      expect(response.status).to eq(401)
    end
  end

  describe "POST with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      payload = {
        "fqdn":"switch.example.org"
      }
      api_post_json(action: "switches", token: @api_token, payload: payload, version: "3")
      expect(response.status).to eq(401)
    end
  end
end

