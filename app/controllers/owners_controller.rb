class OwnersController < ApplicationController
  def index
    @owners = Owner.all
  end

  def show
    @owner = Owner.eager_find(params[:id])

    if IDB.config.modules.lexware_rt_crm_api && @owner.customer_id
      url = "#{IDB.config.modules.lexware_rt_crm_api}/customers/#{@owner.customer_id}"
      response = make_request(url)
      @owner.data = JSON.parse(response.body) if response && response.code == "200"
    end
  end

  def new
    @owner = Owner.new
  end

  def create
    @owner = Owner.new(owner_params)

    if @owner.save
      add_attachments(params[:attachments])
      trigger_version_change(@owner, current_user.display_name)
      redirect_to owner_path(@owner), notice: 'Owner created'
    else
      render :new
    end
  end

  def edit
    @owner = Owner.find(params[:id])
  end

  def update
    @owner = Owner.find(params[:id])

    if @owner.update(owner_params)
      add_attachments(params[:attachments])
      trigger_version_change(@owner, current_user.display_name)
      redirect_to owner_path(@owner), notice: 'Owner updated'
    else
      render :edit
    end
  end

  def destroy
    @owner = Owner.find(params[:id])

    @owner.destroy
    OwnerDeleteWorker.perform_async(@owner.name, current_user.display_name)


    render json: {success: true, redirectTo: owners_path}, notice: 'DELETED'
  end

  def summary
    @owner = Owner.find(params[:owner])
    @machines = @owner.machines
    @networks = Network.where(owner: @owner)
    @cloud_providers = @owner.cloud_providers
    render :summary
  end

  private

  def owner_params
    params.require(:owner).permit(:name, :nickname, :customer_id, :description, :wiki_url, :repo_url, :announcement_contact, :attachments, {user_ids: []})
  end

  def add_attachments(attachments)
    if attachments
      attachments.each { |attachment|
        @owner.attachments.create(attachment: attachment)
      }
    end
  end

  def make_request(url, method = "get")
    begin
      response = HttpHelper.req(url, method)
    rescue StandardError => e
      flash[:error] = e.message
      return
    end
  end
end
