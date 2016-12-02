class LocationLevelPresenter < Keynote::Presenter
  presents :location_level

  delegate :id, :name, :description, :level,
           to: :location_level

  def name_link
    link_to(location_level.name, location_level)
  end

end
