require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Machines API V3' do

  before :each do
    IDB.config.modules.api.v1_enabled = false
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true

    @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)

    FactoryGirl.create :machine, owner: @owner
    FactoryGirl.create :api_token, owner: @owner
    @api_token = FactoryGirl.build :api_token, owner: @owner
    @api_token_r = FactoryGirl.create :api_token_r, owner: @owner
    @api_token_w = FactoryGirl.create :api_token_w, owner: @owner
    @api_token_rw = FactoryGirl.create :api_token_rw, owner: @owner

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

    it 'should only return machines of the api token owner' do
      wrong_owner = FactoryGirl.create(:owner)
      # this machine should not be returned
      FactoryGirl.create :machine, owner: wrong_owner

      api_get(action: "machines", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      # expect just the machine added in before block
      expect(machines.size).to eq(1)
    end

    it "returns machines for all owners for multiple tokens" do
      user = FactoryGirl.create(:user)
      owner_1 = FactoryGirl.create(:owner, users: [user])
      owner_2 = FactoryGirl.create(:owner, users: [user])
      token_1 = FactoryGirl.create :api_token_r, owner: owner_1, name: "FOOBARTOKEN1"
      token_2 = FactoryGirl.create :api_token_r, owner: owner_2, name: "FOOBARTOKEN2"
      allow(User).to receive(:current).and_return(owner_1.users.first)
      allow(User).to receive(:current).and_return(owner_2.users.first)

      m1 = FactoryGirl.create(:machine, fqdn: "foobar.example.org", owner: owner_1)
      m2 = FactoryGirl.create(:machine, fqdn: "bazbar.example.org", owner: owner_2)

      get "/api/v3/machines", headers: {'X-IDB-API-Token': "#{token_1.token}, #{token_2.token}" }
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      expect(machines.size).to eq(2)
      expect(machines[0]['fqdn']).to eq(Machine.first.fqdn)
      expect(machines[1]['fqdn']).to eq(Machine.last.fqdn)
    end

    it "returns machines for all owners for multiple tokens but no machines owned by other owners" do
      user = FactoryGirl.create(:user)
      owner_1 = FactoryGirl.create(:owner, users: [user])
      owner_2 = FactoryGirl.create(:owner, users: [user])
      owner_3 = FactoryGirl.create(:owner, users: [user])

      token_1 = FactoryGirl.create :api_token_r, owner: owner_1, name: "FOOBARTOKEN1"
      token_2 = FactoryGirl.create :api_token_r, owner: owner_2, name: "FOOBARTOKEN2"
      allow(User).to receive(:current).and_return(owner_1.users.first)
      allow(User).to receive(:current).and_return(owner_2.users.first)
      allow(User).to receive(:current).and_return(owner_3.users.first)

      m1 = FactoryGirl.create(:machine, fqdn: "foobar.example.org", owner: owner_1)
      m2 = FactoryGirl.create(:machine, fqdn: "bazbar.example.org", owner: owner_2)
      m3 = FactoryGirl.create(:machine, fqdn: "notowned.example.org", owner: owner_3)

      get "/api/v3/machines", headers: {'X-IDB-API-Token': "#{token_1.token}, #{token_2.token}" }
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      expect(machines.size).to eq(2)
      expect(machines[0]['fqdn']).to eq(Machine.first.fqdn)
      expect(machines[1]['fqdn']).to eq(Machine.second.fqdn)
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

  describe "GET /machines/{fqdn}" do
    it 'should return the corresponding machine' do
      api_get(action: "machines/#{Machine.last.fqdn}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq(Machine.last.fqdn)
    end

    it 'should return empty JSON and code 404 if machine not found' do
      api_get(action: "machines/does.not.exist", token: @api_token_r, version: "3")
      expect(response.status).to eq(404)

      machine = JSON.parse(response.body)
      expect(machine).to eq({"response_type" => "error", "response" => "Not Found"})
    end

    it 'should return the token usable for updating this machine' do
      api_get(action: "machines/#{Machine.last.fqdn}", token: @api_token_rw, version: "3")
      expect(response.status).to eq(200)

      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq(Machine.last.fqdn)
      expect(response.headers["X-Idb-Api-Token"]).to eq(@api_token_rw.token)
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
      FactoryGirl.create(:machine, fqdn: "existing.example.com", owner: @owner)

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
      FactoryGirl.create(:machine, fqdn: "existing2.example.com", cores: 3, owner: @owner)

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
      FactoryGirl.create(:machine, fqdn: "existing3.example.com", cores: 3, owner: @owner)

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

    it 'returns 409 Bad Request for not defined attributes' do
      FactoryGirl.create(:machine, fqdn: "existing3.example.com", cores: 3, owner: @owner)

      api_get(action: "machines/existing3.example.com", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(machine['fqdn']).to eq("existing3.example.com")


      payload = {
        "fqdn":"existing3.example.com",
        "zzz":"fhfhf"
      }

      api_put_json(action: "machines/existing3.example.com", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(409)
    end

    it 'updates the software of a machine if existing, JSON payload' do
      FactoryGirl.create(:machine, fqdn: "existing.example.com", owner: @owner)

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

  describe "GET /machines/{fqdn}/aliases" do
    it "returns the aliases of the machine" do
      m = FactoryGirl.create(:machine, fqdn: "test.example.com", owner: @owner)
      FactoryGirl.create(:machine_alias, name: "alias-1.example.com", machine: m)
      FactoryGirl.create(:machine_alias, name: "alias-2.example.com", machine: m)

      api_get(action: "machines/test.example.com/aliases", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      aliases = JSON.parse(response.body)
      expect(aliases.size).to eq(2)
      expect(aliases[0]['name']).to eq("alias-1.example.com")
      expect(aliases[1]['name']).to eq("alias-2.example.com")
    end
  end

  describe "POST /machines/{fqdn}/aliases" do
    it "creates a new alias for the machine" do
      m = FactoryGirl.create(:machine, fqdn: "test.example.com", owner: @owner)

      payload = {
        "name":"alias-1.example.com"
      }

      api_post_json(action: "machines/test.example.com/aliases", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      as = JSON.parse(response.body)
      expect(as['name']).to eq("alias-1.example.com")
    end
  end

  describe "PUT /machines/{fqdn}/aliases/{name}" do
    it "updates an alias" do
      m = FactoryGirl.create(:machine, fqdn: "test.example.com", owner: @owner)
      a = FactoryGirl.create(:machine_alias, name: "alias-1.example.com", machine: m)

      payload = {
        "name":"alias-2.example.com"
      }

      api_put_json(action: "machines/test.example.com/aliases/alias-1.example.com", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(200)

      as = JSON.parse(response.body)
      expect(as['name']).to eq("alias-2.example.com")

      expect(MachineAlias.last.name).to eq("alias-2.example.com")
    end
  end

  describe "DELETE /machines/{fqdn}/aliases/{name}" do
    it "deletes an alias" do
      m = FactoryGirl.create(:machine, fqdn: "test.example.com", owner: @owner)
      a = FactoryGirl.create(:machine_alias, name: "alias-1.example.com", machine: m)

      api_delete(action: "machines/test.example.com/aliases/alias-1.example.com", token: @api_token_w, version: "3")
      expect(response.status).to eq(204)

      expect(MachineAlias.find_by_name "alias-1.example.com").to be_nil
    end
  end

  describe "GET /machines/{fqdn}/attachments" do
    it "shows all attachments" do
      m = FactoryGirl.create(:machine, fqdn: "test.example.com", owner: @owner)
      FactoryGirl.create(:attachment, machine: m, owner: @owner)
      FactoryGirl.create(:attachment, machine: m, owner: @owner)

      api_get(action: "machines/test.example.com/attachments", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      attachments = JSON.parse(response.body)
      expect(attachments.size).to eq(2)
    end
  end

  describe "POST /machines/{fqdn}/attachments" do
    it "create a new attachment" do
      m = FactoryGirl.create(:machine, fqdn: "test.example.com", owner: @owner)

      post "/api/v3/machines/test.example.com/attachments", headers: {'X-IDB-API-Token': @api_token_w.token }, params: { :data => Rack::Test::UploadedFile.new(Rails.root.join("app","assets","images","idb-logo.png"), "image/png")}
      expect(response.status).to eq(201)

      attachments = JSON.parse(response.body)
      expect(attachments["attachment_fingerprint"]).to eq("85d0dfbc64bfb401df3d98f246a12be41d318a91de452c844e0d3b5c3f884ca4")
      expect(Attachment.last.attachment_fingerprint).to eq("85d0dfbc64bfb401df3d98f246a12be41d318a91de452c844e0d3b5c3f884ca4")
    end
  end

  describe "GET /machines/{fqdn}/attachments/{fingerprint}" do
    it "shows a single attachment" do
      m = FactoryGirl.create(:machine, fqdn: "test.example.com", owner: @owner)
      FactoryGirl.create(:attachment, machine: m, attachment: File.new(Rails.root.join("app","assets","images","idb-logo.png")), owner: @owner)

      api_get(action: "machines/test.example.com/attachments/85d0dfbc64bfb401df3d98f246a12be41d318a91de452c844e0d3b5c3f884ca4", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      attachment = JSON.parse(response.body)
      expect(attachment["attachment_fingerprint"]).to eq("85d0dfbc64bfb401df3d98f246a12be41d318a91de452c844e0d3b5c3f884ca4")
    end
  end

  describe "DELETE /machines/{fqdn}/attachments/{fingerprint}" do
    it "deletes a single attachment" do
      m = FactoryGirl.create(:machine, fqdn: "test.example.com", owner: @owner)
      a = FactoryGirl.create(:attachment, machine: m, owner: @owner)

      api_delete(action: "machines/test.example.com/attachments/#{Attachment.last.attachment_fingerprint}", token: @api_token_w, version: "3")
      expect(response.status).to eq(204)
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
      FactoryGirl.create(:machine, fqdn: "borken.example.com", owner: @owner)

      payload = {
        "fqdn":"borken.example.com"
      }
      api_put_json(action: "machines/borken.example.com", token: @api_token, payload: payload, version: "3")
      expect(response.status).to eq(401)
    end
  end

  describe "POST machines" do
    it "sets raw_api_data" do
      payload = {
        "fqdn":"foobar.example.com"
      }
      api_post_json(action: "machines", token: @api_token_w, payload: payload, version: "3")
      raw = Machine.last.raw_data_api
      expect(JSON.parse(raw)[@api_token_w.name]).to be
      expect(JSON.parse(raw)[@api_token_w.name]["fqdn"]).to eq("foobar.example.com")
    end
  end

  describe "PUT machines/{fqdn}" do
    it "adds raw_api_data" do
      m = FactoryGirl.create(:machine, owner: @owner)

      payload = {
        "fqdn":m.fqdn,
        "cores":8
      }
      api_put_json(action: "machines/#{m.fqdn}", token: @api_token_w, payload: payload, version: "3")
      raw = Machine.last.raw_data_api
      expect(JSON.parse(raw)[@api_token_w.name]).to be
      expect(JSON.parse(raw)[@api_token_w.name]["cores"]).to eq(8)
    end
  end
  
  describe "GET machines" do

  end
end

