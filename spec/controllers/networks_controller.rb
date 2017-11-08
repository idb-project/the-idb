require 'spec_helper'

describe NetworksController do
  before(:each) do
    @current_user = FactoryGirl.create :user
    owner = FactoryGirl.create(:owner, users: [@current_user])
    @machine = FactoryGirl.create(:machine, owner: owner)
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
      2.times {FactoryGirl.create :network}
      get :index
      expect(assigns(:networks)).to eq(Network.all)
    end

    it "returns all machines with duplicate mac addresses, no duplicates" do
      FactoryGirl.create :nic, machine: @machine
      FactoryGirl.create :nic, mac: "ff:ee:dd:cc:bb:aa", machine: @machine
      get :index
      expect(assigns(:duplicated_macs).size).to eq(0)
    end

    it "returns all machines with duplicate mac addresses" do
      FactoryGirl.create :nic, mac: "aa:bb:cc:dd:ee:ff", machine: @machine
      FactoryGirl.create :nic, mac: "aa:bb:cc:dd:ee:ff", machine: @machine
      FactoryGirl.create :nic, mac: "ff:ee:dd:cc:bb:aa", machine: @machine
      get :index
      expect(assigns(:duplicated_macs).size).to eq(2)
    end

    it "returns all machines with duplicate mac addresses, no machine associated, admin user" do
      allow(@current_user).to receive(:is_admin?).and_return(true)
      allow(User).to receive(:current).and_return(@current_user)

      FactoryGirl.create :nic, mac: "aa:bb:cc:dd:ee:ff", machine: nil
      FactoryGirl.create :nic, mac: "aa:bb:cc:dd:ee:ff", machine: nil
      FactoryGirl.create :nic, mac: "ff:ee:dd:cc:bb:aa", machine: nil
      get :index
      expect(assigns(:duplicated_macs).size).to eq(2)
    end
  end
end
