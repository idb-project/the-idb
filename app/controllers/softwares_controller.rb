class SoftwaresController < ApplicationController
  def index
    @machines = SoftwareHelper.software_machines(Machine.all, params["package"], params["version"])
    @package = params["package"]
    @version = params["version"]
  end
end
