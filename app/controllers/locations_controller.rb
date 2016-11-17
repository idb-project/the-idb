class LocationsController < ApplicationController
  def index
    @locations = Location.depth_traverse
  end

  def new
    @location = Location.new
    @locations = {}
    @all_locations = Location.all
    @location_levels = LocationLevel.all
  end

  def create
    @location_levels = LocationLevel.all
    @all_locations = Location.all

    if params[:location][:location_level_id].to_i == 1
      @location = Location.new(params.require(:location).permit(:name, :description, :location_level_id))
    else
      parent_location = Location.find(params[:location][:location_id].to_i)
      @location = Location.new(params.require(:location).permit(:name, :description, :location_level_id))
      parent_location.add_child(@location)
    end

    if @location.save
      redirect_to locations_path
    else
      render :new
    end
  end

  def show
    @location = Location.find(params[:id])
    @all_locations = Location.all
  end

  def edit
    @location = Location.find(params[:id])
    @locations = {}
    @all_locations = Location.depth_traverse
    @location_levels = LocationLevel.all
  end

  def update
    @location = Location.find(params[:id])

    if @location.update(params.require(:location).permit(:name, :level, :description, :location_id))
      redirect_to locations_path, notice: 'Location updated'
    else
      render :edit
    end
  end

  def destroy
    location = Location.find(params[:id])
    if not location.root?
      new_parent = location.parent

      location.children.each do |child_location|
        new_parent.add_child child_location
      end
    end

    location.destroy

    redirect_to locations_path, notice: 'Location deleted, moved children to parent node.'
  end

  def get_parent_locations
    locations = Location.joins(:location_level).where("location_levels.id = ? -1", params[:level].to_i).order(:name)

    render json: locations
  end
end
