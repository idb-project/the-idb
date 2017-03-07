class CloudProvidersController < ApplicationController
  before_action :require_admin_user

  def index
    @cloud_providers = CloudProvider.all
  end

  def new
    @cloud_provider = CloudProvider.new
    @cloud_providers = {}
    @all_cloud_providers = CloudProvider.all
    @owners = Owner.all
  end

  def create
    @cloud_provider = CloudProvider.new(params.require(:cloud_provider).permit(:name, :description, :owner_id, :config, :apidocs))
    @owners = Owner.all

    if params["check"] == "json"
      begin
        JSON.parse(@cloud_provider.config)
      rescue JSON::ParserError
        flash.alert = "JSON validation failed, check the config for errors!"
        render :new
        return
      end
    end

    if @cloud_provider.save
      flash.notice = "Cloud provider created"
      redirect_to cloud_providers_path
    else
      render :new
    end
  end

  def show
    @cloud_provider = CloudProvider.find(params[:id])
    @all_cloud_providers = CloudProvider.all
  end

  def edit
    @cloud_provider = CloudProvider.find(params[:id])
    @cloud_providers = {}
    @all_cloud_providers = CloudProvider.all
    @owners = Owner.all
  end

  def update
    @cloud_provider = CloudProvider.find(params[:id])
    @owners = Owner.all

    if params["check"] == "json"
      begin
        JSON.parse(params[:cloud_provider][:config])
      rescue JSON::ParserError
        flash.alert = "JSON validation failed, check the config for errors!"
        render :new
        return
      end
    end

    if @cloud_provider.update(params.require(:cloud_provider).permit(:name, :description, :owner_id, :config, :apidocs))
      redirect_to cloud_providers_path, notice: 'Cloud Provider updated.'
    else
      render :edit
    end
  end

  def destroy
    @cloud_provider = CloudProvider.find(params[:id])
    @cloud_provider.destroy

    redirect_to cloud_providers_path, notice: 'Cloud Provider deleted!'
  end

end
