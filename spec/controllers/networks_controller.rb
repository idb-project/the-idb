require 'spec_helper'

describe NetworksController do
  before(:each) do
    @current_user = FactoryBot.create :user
    owner = FactoryBot.create(:owner, users: [@current_user])
    @machine = FactoryBot.create(:machine, owner: owner)
    allow(User).to receive(:current).and_return(@current_user)
    controller.session[:user_id] = @current_user.id
  end

  describe "GET index" do
    it "renders the :index template" do
      get :index
      expect(response).to render_template('index')
    end

    it "returns all Networks, none existing" do
      get :index
      expect(assigns(:networks).size).to eq(0)
    end

    it "returns all Networks, two existing" do
      2.times {FactoryBot.create :network}
      get :index
      expect(assigns(:networks)).to eq(Network.all)
    end

    it "returns all machines with duplicate mac addresses, no duplicates" do
      FactoryBot.create :nic, machine: @machine
      FactoryBot.create :nic, mac: "ff:ee:dd:cc:bb:aa", machine: @machine
      get :index
      expect(assigns(:duplicated_macs).size).to eq(0)
    end

    it "returns all machines with duplicate mac addresses" do
      FactoryBot.create :nic, mac: "aa:bb:cc:dd:ee:ff", machine: @machine
      FactoryBot.create :nic, mac: "aa:bb:cc:dd:ee:ff", machine: @machine
      FactoryBot.create :nic, mac: "ff:ee:dd:cc:bb:aa", machine: @machine
      get :index
      expect(assigns(:duplicated_macs).size).to eq(2)
    end

    it "returns all machines with duplicate mac addresses, no machine associated, admin user" do
      allow(@current_user).to receive(:is_admin?).and_return(true)
      allow(User).to receive(:current).and_return(@current_user)

      FactoryBot.create :nic, mac: "aa:bb:cc:dd:ee:ff", machine: nil
      FactoryBot.create :nic, mac: "aa:bb:cc:dd:ee:ff", machine: nil
      FactoryBot.create :nic, mac: "ff:ee:dd:cc:bb:aa", machine: nil
      get :index
      expect(assigns(:duplicated_macs).size).to eq(2)
    end
  end
end
