class MachinesController < ApplicationController
  def index
    if params[:fqdn]
      @machine = Machine.find_by_fqdn(params[:fqdn])
      if @machine
        @inventories = Inventory.where(machine_id: @machine.id)
        render :show
      else
        redirect_to root_path
      end
    else
      @machines = Machine.includes(:owner, nics: [:ip_address]).order(:fqdn)
    end
  end

  def show
    @machine = Machine.find(params[:id])
    @inventories = Inventory.where(machine_id: @machine.id)
  end

  def new
    @machine = params[:machine] ? Machine.new(params.require(:machine).permit(:fqdn)) : Machine.new
    @machine.owner = Owner.first # preset of the owner list
    @form_locations = Location.depth_traverse
  end

  def create
    @machine = Machine.new(params.require(:machine).permit(:fqdn, :description, :owner_id, :backup_type))
    @machine.power_feed_a = Location.find(params[:machine][:power_feed_a]) unless params[:machine][:power_feed_a].blank?
    @machine.power_feed_b = Location.find(params[:machine][:power_feed_b]) unless params[:machine][:power_feed_b].blank?
    @form_locations = Location.depth_traverse

    @power_feed_a_id = @machine.power_feed_a.nil? ? "" : @machine.power_feed_a.id
    @power_feed_b_id = @machine.power_feed_b.nil? ? "" : @machine.power_feed_b.id

    if @machine.save
      add_attachments(params[:attachments])
      MachineUpdateWorker.perform_async(@machine.fqdn)
      trigger_version_change(@machine, current_user.display_name)
      redirect_to machines_path
    else
      render :new
    end
  end

  def edit
    @machine = Machine.find(params[:id])
    @power_feed_a_id = @machine.power_feed_a.nil? ? "" : @machine.power_feed_a.id
    @power_feed_b_id = @machine.power_feed_b.nil? ? "" : @machine.power_feed_b.id
    @power_supplies = Location.joins(:location_level).where("location_levels.level = ?", 50).order(:name).each{|l| l.name=l.name + " ("+l.location_name+")"}
    @machine_details = EditableMachineForm.new(@machine)
    @form_locations = Location.depth_traverse
  end

  def update
    @machine = Machine.find(params[:id])
    @form_locations = Location.depth_traverse
    @machine_details = EditableMachineForm.new(@machine)

    if params[:machine][:power_feed_a].blank?
      @machine.power_feed_a = nil
    else
      @machine.power_feed_a = Location.find(params[:machine][:power_feed_a])
    end
    if params[:machine][:power_feed_b].blank?
      @machine.power_feed_b = nil
    else
      @machine.power_feed_b = Location.find(params[:machine][:power_feed_b])
    end

    @power_feed_a_id = @machine.power_feed_a.nil? ? "" : @machine.power_feed_a.id
    @power_feed_b_id = @machine.power_feed_b.nil? ? "" : @machine.power_feed_b.id

    if @machine.update(machine_params.permit!)
      add_attachments(params[:attachments])
      trigger_version_change(@machine, current_user.display_name)
      redirect_to machine_path(@machine), notice: 'Machine updated!'
    else
      render :edit
    end
  end

  def update_details
    @machine = Machine.find(params[:machine_id])
    @machine_details = EditableMachineForm.new(@machine)
    @form_locations = Location.depth_traverse

    @power_feed_a_id = @machine.power_feed_a.nil? ? "" : @machine.power_feed_a.id
    @power_feed_b_id = @machine.power_feed_b.nil? ? "" : @machine.power_feed_b.id

    update_status = @machine.update_details(params, @machine_details)
    if update_status
      # only trigger version change if base attributes have changed
      trigger_version_change(@machine, current_user.display_name) unless update_status.empty?
      redirect_to machine_path(@machine), notice: 'Machine updated!'
    else
      render :edit, error: 'Update failed!'
    end
  end

  def destroy
    @machine = Machine.find(params[:id])
    fqdn = @machine.fqdn
    @machine.destroy
    MachineDeleteWorker.perform_async(fqdn, current_user.display_name)

    render json: {success: true, redirectTo: machines_path}, notice: 'DELETED'
  end

  private

  def machine_params
    params.require(:machine).permit(:fqdn, :description, :owner_id, :backup_type, :auto_update, :switch_url, :mrtg_url, :config_instructions, :sw_characteristics, :business_purpose, :business_criticality, :business_notification, :attachments, :needs_reboot)
  end

  def add_attachments(attachments)
    if attachments
      attachments.each { |attachment|
        @machine.attachments.create(attachment: attachment)
      }
    end
  end
end
