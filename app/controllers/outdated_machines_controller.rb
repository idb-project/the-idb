class OutdatedMachinesController < ApplicationController
  def index
    @outdated_machines = Machine.where(["updated_at < ? and auto_update = true", 1.day.ago] )
  end
end
