class InventoryStatusController < ApplicationController
  before_action :require_admin_user

  def index
    @all_inventory_status = InventoryStatus.order(name: :asc)
  end

  def new
    @inventory_status = InventoryStatus.new
    @all_inventory_status = InventoryStatus.order(name: :asc)
  end

  def create
    @inventory_status = InventoryStatus.new(params.require([:inventory_status][0]).permit(:name, :inactive))
    if @inventory_status.save
      redirect_to inventory_status_index_path
    else
      render :new
    end
  end

  def show
    @inventory_status = InventoryStatus.find(params[:id])
    @all_inventory_status = InventoryStatus.order(name: :asc)
  end

  def edit
    @inventory_status = InventoryStatus.find(params[:id])
    @all_inventory_status = InventoryStatus.order(name: :asc)
  end

  def update
    @inventory_status = InventoryStatus.find(params[:id])

    if @inventory_status.update(params.require(:inventory_status).permit(:name, :inactive))
      redirect_to inventory_status_index_path, notice: 'Inventory status updated'
    else
      render :edit
    end
  end

  def destroy
    @inventory_status = InventoryStatus.find(params[:id])
    @inventory_status.destroy

    redirect_to inventory_status_index_path, notice: 'Inventory status deleted!'
  end

end
