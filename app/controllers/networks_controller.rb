class NetworksController < ApplicationController
  def index
    @networks = Network.all
    @duplicated_macs = Nic.find_by_sql(%q{select nics.mac, nics.machine_id from nics join ( select mac, machine_id, count(*) from nics group by mac, machine_id having count(*) > 1) as dups on dups.mac =
 nics.mac;})
    @machines = Machine.all
  end

  def show
    @network = Network.find(params[:id])
  end

  def new
    @network = Network.new
  end

  def create
    @network = Network.new(safe_params)

    if @network.save
      trigger_version_change(@network, current_user.display_name)
      redirect_to networks_path
    else
      render :new
    end
  end

  def edit
    @network = Network.find(params[:id])
  end

  def update
    @network = Network.find(params[:id])

    if @network.update(safe_params)
      trigger_version_change(@network, current_user.display_name)
      redirect_to network_path(@network), notice: 'Network updated!'
    else
      render :edit
    end
  end

  def destroy
    @network = Network.find(params[:id])
    @network.destroy

    render json: {success: true, redirectTo: networks_path}, notice: 'DELETED'
  end

  private

  def safe_params
    params.require(:network).permit(
      :name, :address, :description, :owner_id,
      :allowed_ip_addresses => []
    )
  end
end
