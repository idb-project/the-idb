class VersionsController < ApplicationController
  def show
    @version = PaperTrail::Version.find(params[:id])
  end
end
