class AttachmentsController < ApplicationController
  def destroy
    attachment = Attachment.find(params[:id])
    inventory = attachment.inventory
    owner = attachment.owner
    machine = attachment.machine

    attachment.destroy

    if owner
      redirect_to edit_owner_path(owner)
    elsif inventory
      redirect_to edit_inventory_path(inventory)
    elsif machine
      redirect_to edit_machine_path(machine)
    else
      redirect_to root_url
    end
  end
end
