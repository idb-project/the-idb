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

    # we need this because papertrail cant be given a item_type to use for storage, it always
    # uses the classname. as switches and virtual machines are machines, cast them to machine 
    # for showing the history.
    @history_machine = Machine.find(params[:id]).becomes(Machine)

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

    @machine_details.nics.each do |nic|
      if nic.mac and Nic.where(mac: nic.mac).count > 1
        flash.alert = "Duplicate MAC address " + nic.mac
      end
    end
  end

  def destroy
    @machine = Machine.find(params[:id])
    fqdn = @machine.fqdn
    @machine.destroy
    MachineDeleteWorker.perform_async(fqdn, current_user.display_name)

    render json: {success: true, redirectTo: machines_path}, notice: 'DELETED'
  end

  def autocomplete_config_instructions
    autocomplete_general("config_instructions", params[:term])
  end

  def autocomplete_sw_characteristics
    autocomplete_general("sw_characteristics", params[:term])
  end

  def autocomplete_business_purpose
    autocomplete_general("business_purpose", params[:term])
  end

  def autocomplete_business_criticality
    autocomplete_general("business_criticality", params[:term])
  end

  def autocomplete_business_notification
    autocomplete_general("business_notification", params[:term])
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

  def autocomplete_general(attrib, term)
    render json: Machine.where("#{attrib} like '%#{term}%'").pluck("distinct #{attrib}")
  end
end
