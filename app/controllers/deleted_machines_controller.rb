class DeletedMachinesController < ApplicationController
  def index
    @deleted_machines = Machine.unscope(where: :deleted_at).where.not(deleted_at: nil)
  end

  def edit
    @machine = Machine.unscope(where: :deleted_at).find(params[:id])
    @machine.restore
    @inventories = Inventory.where(machine_id: @machine.id)
    render "machines/show"
  end

  def destroy
    @machine = Machine.unscope(where: :deleted_at).find(params[:id])
    @machine.really_destroy!

    @deleted_machines = Machine.unscope(where: :deleted_at).where.not(deleted_at: nil)
    render "index"
  end
end
