require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Inventories API V3' do

  before :each do
    IDB.config.modules.api.v2_enabled = false
    IDB.config.modules.api.v3_enabled = true

    @owner = FactoryBot.create(:owner, users: [FactoryBot.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)

    FactoryBot.create :inventory, owner: @owner
    FactoryBot.create :api_token, owner: @owner
    @api_token = FactoryBot.build :api_token, owner: @owner
    @api_token_r = FactoryBot.create :api_token_r, owner: @owner
    @api_token_w = FactoryBot.create :api_token_w, owner: @owner

    # prevent execution of VersionChangeWorker, depends on running sidekiq workers
    allow(VersionChangeWorker).to receive(:perform_async) do |arg|
      nil
    end
  end
  
  describe "API is switched off" do
    it 'should not allow access' do
      IDB.config.modules.api.v3_enabled = false

      api_get(action: "inventories", token: @api_token_r, version:"3")
      expect(response.status).to eq(501)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"API disabled."})
    end
  end

  describe "GET /inventories but unauthorized" do
    it 'should return json error message' do
      api_get_unauthorized(action: "inventories", version: "3")

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body)).to eq({"response_type"=>"error", "response"=>"Unauthorized."})
    end
  end

  describe "GET /inventories" do
    it 'should return all inventories' do
      api_get(action: "inventories", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      inventories = JSON.parse(response.body)
      expect(inventories.size).to eq(1)
      expect(inventories[0]['inventory_number']).to eq(Inventory.last.inventory_number)
    end

    it "returns inventories for all owners for multiple tokens" do
      user = FactoryBot.create(:user)
      owner_1 = FactoryBot.create(:owner, users: [user])
      owner_2 = FactoryBot.create(:owner, users: [user])
      token_1 = FactoryBot.create :api_token_r, owner: owner_1, name: "FOOBARTOKEN1"
      token_2 = FactoryBot.create :api_token_r, owner: owner_2, name: "FOOBARTOKEN2"
      allow(User).to receive(:current).and_return(owner_1.users.first)
      allow(User).to receive(:current).and_return(owner_2.users.first)

      i1 = FactoryBot.create(:inventory, inventory_number: "abcdef", owner: owner_1)
      i2 = FactoryBot.create(:inventory, inventory_number: "ghijkl", owner: owner_2)

      get "/api/v3/inventories", headers: {'X-IDB-API-Token': "#{token_1.token}, #{token_2.token}" }
      expect(response.status).to eq(200)

      inventories = JSON.parse(response.body)
      expect(inventories.size).to eq(2)
      expect(inventories[0]['inventory_number']).to eq(Inventory.first.inventory_number)
      expect(inventories[1]['inventory_number']).to eq(Inventory.last.inventory_number)
    end
  end

  describe "GET /inventories/{inventory_number}" do
    it "should return an inventory item and set X-Idb-Api-Token header to token usable for updating" do
      user = FactoryBot.create(:user)
      owner_1 = FactoryBot.create(:owner, users: [user])
      owner_2 = FactoryBot.create(:owner, users: [user])
      token_1 = FactoryBot.create :api_token_rw, owner: owner_1, name: "FOOBARTOKEN1"
      token_2 = FactoryBot.create :api_token_r, owner: owner_2, name: "FOOBARTOKEN2"
      allow(User).to receive(:current).and_return(owner_1.users.first)
      allow(User).to receive(:current).and_return(owner_2.users.first)

      inv = FactoryBot.create(:inventory, owner: owner_1)

      get "/api/v3/inventories/#{inv.inventory_number}", headers: {'X-IDB-API-Token': "#{token_1.token}, #{token_2.token}" }
      expect(response.status).to eq(200)

      expect(response.header["X-Idb-Api-Token"]).to eq(token_1.token)

      json_inv = JSON.parse(response.body)
      expect(json_inv["inventory_number"]).to eq(inv.inventory_number)
    end
  end

  describe "GET /inventories?inventory_number=" do
    it 'should filter inventory items for items with this inventory_number' do
      api_get(action: "inventories?inventory_number=#{Inventory.last.inventory_number}", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      inventory = JSON.parse(response.body)
      expect(inventory.size).to eq(1)
      expect(inventory[0]['inventory_number']).to eq(Inventory.last.inventory_number)
    end

    it 'should return empty JSON array and if no inventory item matches' do
      api_get(action: "inventories?inventory_number=nonexisting_inventory", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      machines = JSON.parse(response.body)
      expect(machines).to eq([])
    end
  end

  describe "POST /inventories" do
    it 'creates an inventory item' do
      api_get(action: "inventories/inventory_test_item", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(machine).to eq("response_type"=>"error", "response"=>"Not found")

      payload = {
        "inventory_number":"inventory_test_item"
      }
      api_post_json(action: "inventories", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      inventory = JSON.parse(response.body)
      expect(inventory['inventory_number']).to eq("inventory_test_item")
    end

    it 'creates an inventory item if not existing, entering the API token name into the history' do
      api_get(action: "inventories/inventory_test_item", token: @api_token_r, version: "3")
      machine = JSON.parse(response.body)
      expect(machine).to eq("response_type"=>"error", "response"=>"Not found")

      payload = {
        "inventory_number":"inventory_test_item"
      }
      api_post_json(action: "inventories", token: @api_token_w, payload: payload, version: "3")
      expect(response.status).to eq(201)

      machine = JSON.parse(response.body)
      expect(Inventory.last.versions.last.whodunnit).to eq(@api_token_w.token)
    end
  end

  describe "PUT /inventories/{inventory_number}" do
    it 'updates an inventory item' do
      FactoryBot.create(:inventory, inventory_number: "existing_inventory", owner: @owner)

      api_get(action: "inventories/existing_inventory", token: @api_token_r, version: "3")
      inventory = JSON.parse(response.body)
      expect(inventory['inventory_number']).to eq("existing_inventory")

      payload = {
        "place":"test_place"
      }
      api_put_json(action: "inventories/existing_inventory", token: @api_token_w, version: "3", payload: payload)
      expect(response.status).to eq(200)
      inventory = JSON.parse(response.body)
      expect(inventory['inventory_number']).to eq("existing_inventory")
      expect(inventory['place']).to eq("test_place")
    end

    it 'updates multiple attributes of in inventory item if existing' do
      FactoryBot.create(:inventory, inventory_number: "existing_inventory", owner: @owner)

      api_get(action: "inventories/existing_inventory", token: @api_token_r, version: "3")
      inventory = JSON.parse(response.body)
      expect(inventory['inventory_number']).to eq("existing_inventory")

      payload = {
        "place":"test_place",
        "comment": "test_comment"
      }
      api_put_json(action: "inventories/existing_inventory", token: @api_token_w, version: "3", payload: payload)
      expect(response.status).to eq(200)
      inventory = JSON.parse(response.body)
      expect(inventory['inventory_number']).to eq("existing_inventory")
      expect(inventory['place']).to eq("test_place")
      expect(inventory['comment']).to eq("test_comment")
    end

    it 'returns 409 Bad Request for not defined attributes' do
      FactoryBot.create(:inventory, inventory_number: "existing_inventory", owner: @owner)

      api_get(action: "inventories/existing_inventory", token: @api_token_r, version: "3")
      inventory = JSON.parse(response.body)
      expect(inventory['inventory_number']).to eq("existing_inventory")

      payload = {
        "place":"test_place",
        "foobar": "foobaz"
      }
      api_put_json(action: "inventories/existing_inventory", token: @api_token_w, version: "3", payload: payload)
      expect(response.status).to eq(409)
    end
  end

  describe "GET /inventories/{inventory_number}/attachments" do
    it "shows all attachments" do
      i = FactoryBot.create(:inventory, owner: @owner)
      FactoryBot.create(:attachment, inventory: i, owner: @owner)
      FactoryBot.create(:attachment, inventory: i, owner: @owner)

      api_get(action: "inventories/#{Inventory.last.inventory_number}/attachments", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      attachments = JSON.parse(response.body)
      expect(attachments.size).to eq(2)
    end
  end

  describe "POST /inventories/{inventory_number}/attachments" do
    it "create a new attachment" do
      i = FactoryBot.create(:inventory, inventory_number: "123abc", owner: @owner)

      post "/api/v3/inventories/123abc/attachments", headers: {'X-Idb-Api-Token': @api_token_w.token }, params: { :data => Rack::Test::UploadedFile.new(Rails.root.join("app","assets","images","idb-logo.png"), "image/png")}
      expect(response.status).to eq(201)

      attachments = JSON.parse(response.body)
      expect(attachments["attachment_fingerprint"]).to eq("85d0dfbc64bfb401df3d98f246a12be41d318a91de452c844e0d3b5c3f884ca4")
      expect(Attachment.last.attachment_fingerprint).to eq("85d0dfbc64bfb401df3d98f246a12be41d318a91de452c844e0d3b5c3f884ca4")
    end
  end

  describe "GET /inventories/{inventory_number}/attachments/{fingerprint}" do
    it "shows a single attachment" do
      i = FactoryBot.create(:inventory, inventory_number: "123abc", owner: @owner)
      FactoryBot.create(:attachment, inventory: i, attachment: File.new(Rails.root.join("app","assets","images","idb-logo.png")), owner: @owner)

      api_get(action: "inventories/123abc/attachments/85d0dfbc64bfb401df3d98f246a12be41d318a91de452c844e0d3b5c3f884ca4", token: @api_token_r, version: "3")
      expect(response.status).to eq(200)

      attachment = JSON.parse(response.body)
      expect(attachment["attachment_fingerprint"]).to eq("85d0dfbc64bfb401df3d98f246a12be41d318a91de452c844e0d3b5c3f884ca4")
    end
  end

  describe "DELETE /inventories/{inventory_number}/attachments/{fingerprint}" do
    it "deletes a single attachment" do
      i = FactoryBot.create(:inventory, inventory_number: "123abc", owner: @owner)
      a = FactoryBot.create(:attachment, inventory: i, owner: @owner)

      api_delete(action: "inventories/123abc/attachments/#{Attachment.last.attachment_fingerprint}", token: @api_token_w, version: "3")
      expect(response.status).to eq(204)
    end
  end

  describe "GET with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      api_get(action: "inventories", token: @api_token, version: "3")
      expect(response.status).to eq(401)
    end
  end

  describe "POST with wrong token permissions" do
    it 'should return 401 Unauthorized' do
      payload = {
        "inventory_number":"inventory_test_item"
      }
      api_post_json(action: "inventories", token: @api_token, payload: payload, version: "3")
      expect(response.status).to eq(401)
    end
  end
end

