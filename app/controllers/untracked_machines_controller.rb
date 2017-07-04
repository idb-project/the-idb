class UntrackedMachinesController < ApplicationController
  before_action :require_admin_user

  def index
    @untracked_machines = UntrackedMachinesList.new($redis).get.sort
    @untracked_machines.each do |m|
      if Machine.find_by_fqdn(m)
        @untracked_machines.delete(m)
        UntrackedMachinesList.new($redis).set(@untracked_machines)
      end
    end
  end

  def destroy
    @untracked_machines = UntrackedMachinesList.new($redis).get.sort
    @untracked_machines.delete(params[:id])

    UntrackedMachinesList.new($redis).set(@untracked_machines)

    redirect_to untracked_machines_path, notice: 'Untracked machine deleted!'
  end
end
