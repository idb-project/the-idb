require 'spec_helper'

describe CloudProvidersController do
  before(:each) do
    @current_user = FactoryGirl.create(:user, admin: true)
    allow(User).to receive(:current).and_return(@current_user)
    controller.session[:user_id] = @current_user.id
  end

  describe "GET index" do
    it "redirects to root path if user is not an admin" do
      current_user2 = FactoryGirl.create(:user, admin: false)
      controller.session[:user_id] = current_user2.id
      allow(User).to receive(:current).and_return(current_user2)
      get :index
      expect(response).to redirect_to root_path
    end

    it "renders the :index template" do
      get :index
      expect(response).to render_template('index')
    end

    it "returns all CloudProviders, none existing" do
      get :index
      expect(assigns(:cloud_providers)).to eq([])
    end

    it "returns all CloudProviders, two existing" do
      2.times {FactoryGirl.create :cloud_provider}
      get :index
      expect(assigns(:cloud_providers)).to eq(CloudProvider.all)
    end
  end

  describe "GET new" do
    it "renders the :new template" do
      get :new
      expect(response).to render_template('new')
    end

    it "assigns a new cloud provider" do
      get :new
      expect(assigns(:cloud_provider)).to be_a_new(CloudProvider)
    end

    it "assigns all CloudProviders, two existing" do
      2.times {FactoryGirl.create :cloud_provider}
      get :new
      expect(assigns(:all_cloud_providers)).to eq(CloudProvider.all)
    end

    it "assigns all owner, one existing" do
      FactoryGirl.create :owner
      get :new
      expect(assigns(:owners)).to eq(Owner.all)
    end
  end

  describe "POST create, successful" do
    before(:each) do
      post :create, params: {cloud_provider: {name: "Name", description: "Description", config: "\"Text\""}}
    end

    it "creates a new cloud provider" do
      expect(CloudProvider.last.name).to eq("Name")
      expect(CloudProvider.last.description).to eq("Description")
    end

    it "assigns owners" do
      expect(assigns(:owners)).to eq(Owner.all)
    end

    it "redirects to cloud_providers_path" do
      expect(response).to redirect_to(cloud_providers_path)
    end

    it "renders a flash message" do
      expect(flash[:notice]).to be_present
    end
  end

  describe "POST create, unsuccessful" do
    before(:each) do
      post :create, params: {cloud_provider: {description: "Text"}}
    end

    it "does not create a new cloud provider" do
      expect(CloudProvider.all.size).to eq(0)
    end

    it "assigns owners" do
      expect(assigns(:owners)).to eq(Owner.all)
    end

    it "renders the new template" do
      expect(response).to render_template('new')
    end
  end

  describe "POST create, invalid config" do
    before(:each) do
      post :create, params: {cloud_provider: {config: "Text, no JSON"}, check: "json"}
    end

    it "does not create a new cloud provider" do
      expect(CloudProvider.all.size).to eq(0)
    end

    it "assigns owners" do
      expect(assigns(:owners)).to eq(Owner.all)
    end

    it "renders a flash alert" do
      expect(flash[:alert]).to be_present
    end

    it "renders the new template" do
      expect(response).to render_template('new')
    end
  end

  describe "GET show" do
    before(:each) do
      @cp = FactoryGirl.create :cloud_provider
      get :show, params: {id: @cp.id}
    end

    it "assigns a new cloud provider" do
      expect(assigns(:cloud_provider)).to eq(@cp)
    end

    it "assigns all CloudProviders, two existing" do
      2.times {FactoryGirl.create :cloud_provider}
      expect(assigns(:all_cloud_providers)).to eq(CloudProvider.all)
    end
  end

  describe "GET edit" do
    before(:each) do
      @cp = FactoryGirl.create :cloud_provider
      get :edit, params: {id: @cp.id}
    end

    it "renders the :edit template" do
      expect(response).to render_template('edit')
    end

    it "assigns a new cloud provider" do
      expect(assigns(:cloud_provider)).to eq(@cp)
    end

    it "assigns all CloudProviders, two existing" do
      2.times {FactoryGirl.create :cloud_provider}
      expect(assigns(:all_cloud_providers)).to eq(CloudProvider.all)
    end

    it "assigns all owner, one existing" do
      expect(assigns(:owners)).to eq(Owner.all)
    end
  end

  describe "PUT update, successful" do
    before(:each) do
      @cp = FactoryGirl.create :cloud_provider
      put :update, params: {cloud_provider: {name: "Name2", description: "Description2", config: "\"Text\""}, id: @cp.id}
    end

    it "updates the cloud provider" do
      expect(CloudProvider.last.name).to eq("Name2")
      expect(CloudProvider.last.description).to eq("Description2")
    end

    it "assigns owners" do
      expect(assigns(:owners)).to eq(Owner.all)
    end

    it "redirects to cloud_providers_path" do
      expect(response).to redirect_to(cloud_providers_path)
    end

    it "renders a flash message" do
      expect(flash[:notice]).to be_present
    end
  end

  describe "PUT update, unsuccessful" do
    before(:each) do
      @cp = FactoryGirl.create :cloud_provider
      cp2 = FactoryGirl.create :cloud_provider, name: "Name2"
      put :update, params: {cloud_provider: {name: "Name2", description: "Description2", config: "\"Text\""}, id: @cp.id}
    end

    it "does not update the cloud provider" do
      expect(CloudProvider.first.name).not_to eq("Name2")
      expect(CloudProvider.first.description).not_to eq("Description2")
    end

    it "assigns owners" do
      expect(assigns(:owners)).to eq(Owner.all)
    end

    it "redirects to cloud_providers_path" do
      expect(response).to render_template('edit')
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @cp = FactoryGirl.create :cloud_provider
      delete :destroy, params: {id: @cp.id}
    end

    it "updates the cloud provider" do
      expect(CloudProvider.all.size).to eq(0)
    end

    it "redirects to cloud_providers_path" do
      expect(response).to redirect_to(cloud_providers_path)
    end

    it "renders a flash message" do
      expect(flash[:notice]).to be_present
    end
  end
end
