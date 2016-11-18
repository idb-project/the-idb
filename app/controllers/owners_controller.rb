class OwnersController < ApplicationController
  def index
    @owners = Owner.all
  end

  def show
    @owner = Owner.eager_find(params[:id])
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
    render :summary
  end

  private

  def owner_params
    params.require(:owner).permit(:name, :nickname, :customer_id, :description, :wiki_url, :repo_url, :attachments)
  end

  def add_attachments(attachments)
    if attachments
      attachments.each { |attachment|
        @owner.attachments.create(attachment: attachment)
      }
    end
  end
end
