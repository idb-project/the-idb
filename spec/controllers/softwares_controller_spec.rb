require 'spec_helper'

describe SoftwaresController do
  before(:each) do
    @current_user = FactoryGirl.create :user
    owner = FactoryGirl.create(:owner, users: [@current_user])
    allow(User).to receive(:current).and_return(@current_user)
    controller.session[:user_id] = @current_user.id
    create(:machine, owner: owner, software: [{name: "ruby", version: "2.2.5"}, {name: "nginx", version: "1.10.1"}, {name: "python", version: "2.7"}])
    create(:machine, owner: owner, software: [{name: "nginx", version: "1.10.1-0ubuntu1.2"},{name: "python", version: "3.6"}])
  end

  describe "GET index" do
    it "renders the :index template" do
      get :index
      expect(response).to render_template('index')
    end

    it "returns nil machines if no search parameters were provided" do
      get :index
      expect(assigns(:machines)).to be_nil
    end

    it "returns nil machines if empty search parameters were provided" do
      get :index, params: {"q": ""}
      expect(assigns(:machines)).to be_nil
    end

    it "returns all machines matching the search parameters, name only" do
      get :index, params: {"q": "ruby"}
      expect(assigns(:machines).size).to eq(1)

      get :index, params: {"q": "nginx"}
      expect(assigns(:machines).size).to eq(2)
    end

    it "returns all machines matching the search parameters, name and version" do
      get :index, params: {"q": "nginx=1.10.1-0ubuntu1.2"}
      expect(assigns(:machines).size).to eq(1)
    end

    it "returns all machines matching the search parameters, no match" do
      get :index, params: {"q": "apache2"}
      expect(assigns(:machines).size).to eq(0)
    end

    it "returns all machines matching the search parameters, partial version" do
      get :index, params: {"q": "nginx=1.10"}
      expect(assigns(:machines).size).to eq(2)
    end

    it "returns all machines matching the search parameters, not equal version" do
      get :index, params: {"q": "python!=2.7"}
      expect(assigns(:machines).size).to eq(1)
    end
  end
end
