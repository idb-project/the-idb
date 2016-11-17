class LocationLevelsController < ApplicationController
  def index
    @location_levels = LocationLevel.all
  end

  def new
    @location_level = LocationLevel.new
    @location_levels = {}
    @all_location_levels = LocationLevel.all
  end

  def create
    @location_level = LocationLevel.new(params.require([:location_level][0]).permit(:description, :name, :level))
    if @location_level.save
      redirect_to location_levels_path
    else
      render :new
    end
  end

  def show
    @location_level = LocationLevel.find(params[:id])
    @all_location_levels = LocationLevel.all
  end

  def edit
    @location_level = LocationLevel.find(params[:id])
    @location_levels = {}
    @all_location_levels = LocationLevel.all
  end

  def update
    @location_level = LocationLevel.find(params[:id])

    if @location_level.update(params.require(:location_level).permit(:name, :level, :description))
      redirect_to location_levels_path, notice: 'Location Level updated'
    else
      render :edit
    end
  end

  def destroy
    @location_level = LocationLevel.find(params[:id])
    @location_level.destroy

    redirect_to location_levels_path, notice: 'Location Level deleted!'
  end

end
