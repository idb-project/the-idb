class SwitchesController < ApplicationController
  def index
    @switches = Machine.switches.order(:fqdn)
  end
end
