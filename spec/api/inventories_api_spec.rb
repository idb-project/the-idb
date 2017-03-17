require 'spec_helper'
require 'api_helper'
require 'fakeweb'
require 'timecop'

describe 'Inventories API' do

  before :each do
    user = FactoryGirl.create :user
    allow(User).to receive(:current).and_return(user)
    IDB.config.modules.api.v2_enabled = true
    @owner = FactoryGirl.create :owner
    @owner.users << user
    @inventory_a = FactoryGirl.create :inventory, owner: @owner
    @inventory_b = FactoryGirl.create :inventory, owner: @owner
    @api_token = FactoryGirl.create :api_token
    @api_token_r = FactoryGirl.create :api_token_r
    @api_token_w = FactoryGirl.create :api_token_w
  end

  describe "API is switched off" do
    it 'should not allow access' do
      IDB.config.modules.api.v2_enabled = false

      api_get "inventories", @api_token_r
      body = JSON.parse(response.body)
      expect(response.status).to eq(501)
      expect(body["response_type"]).to eq("error")
      expect(body["response"]).to eq("API disabled.")
    end
  end

  describe "GET /inventories" do
    it "returns error with invalid token" do
      api_get "inventories", @api_token

      inventories = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(inventories["response_type"]).to eq("error")
      expect(inventories["response"]).to eq("Unauthorized.")
    end

    it "returns all inventories" do
      api_get "inventories", @api_token_r

      inventories = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(inventories.size).to eq(2)
      expect(inventories.first["inventory_number"]).to eq(@inventory_a.inventory_number)
    end

    it "returns the inventory by id if id param is set" do
      api_get "inventories?id=#{@inventory_a.id}", @api_token_r

      inventories = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(inventories["id"]).to eq(@inventory_a.id)
    end

    it "returns inventory items by number if number param is set" do
      api_get "inventories?number=#{@inventory_a.inventory_number}", @api_token_r

      inventories = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(inventories.first["id"]).to eq(@inventory_a.id)
    end

    it "returns the inventory by id if id param is set" do
      api_get "inventories?id=#{@inventory_a.id}", @api_token_r

      inventories = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(inventories["id"]).to eq(@inventory_a.id)
    end

    it "returns a 404 if no inventory is found" do
      api_get "inventories?id=0", @api_token_r

      inventories = JSON.parse(response.body)
      expect(response.status).to eq(404)
      expect(inventories.size).to eq(0)
    end
  end

  describe "POST /inventories" do
    it "creates a new inventory" do
      p = {
        "inventory_number": "test123",
        "name": "test"
      }
      api_post_json "inventories", @api_token_w, p

      new_inventory = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(new_inventory["inventory_number"]).to eq("test123")
    end
  end

  describe "PUT /inventories" do
    it "updates an existing inventory" do
      new_inventory = Inventory.create({inventory_number: "old", owner: @owner})

      p = {
        "id": new_inventory.id,
        "inventory_number": "updated"
      }

      api_put_json "inventories", @api_token_w, p

      updated_inventory = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(updated_inventory["inventory_number"]).to eq("updated")
    end

    it "does not update an existing inventory if user is not an owner" do
      new_inventory = Inventory.create({inventory_number: "old"})

      p = {
        "id": new_inventory.id,
        "inventory_number": "updated"
      }

      api_put_json "inventories", @api_token_w, p

      updated_inventory = JSON.parse(response.body)
      expect(response.status).to eq(404)
    end
  end
end


