class LocationMachinePresenter < Keynote::Presenter
  presents :machine

  delegate :id, :fqdn, :location,
           to: :machine

  def name_link
    link_to(machine.name, machine)
  end

  def country_edit_link
    country = get_location_by_level(10)
    return link_to country.name, edit_location_path(country) if country
  end

  def city_edit_link
    city = get_location_by_level(20)
    return link_to city.name, edit_location_path(city) if city
  end

  def datacenter_edit_link
    datacenter = get_location_by_level(30)
    return link_to datacenter.name, edit_location_path(datacenter) if datacenter
  end

  def rack_edit_link
    rack = get_location_by_level(40)
    return link_to rack.name, edit_location_path(rack) if rack
  end

  def power_feed_a_edit_link
    feed = machine.power_feed_a
    return link_to feed.name, edit_location_path(feed) if feed
  end

  def country_link
    country = get_location_by_level(10)
    return link_to country.name, location_path(country) if country
  end

  def city_link
    city = get_location_by_level(20)
    return link_to city.name, location_path(city) if city
  end

  def datacenter_link
    datacenter = get_location_by_level(30)
    return link_to datacenter.name, location_path(datacenter) if datacenter
  end

  def rack_link
    rack = get_location_by_level(40)
    return link_to rack.name, location_path(rack) if rack
  end

  def power_feed_a_link
    feed = machine.power_feed_a
    return link_to feed.name, location_path(feed) if feed
  end

  private

  def get_location_by_level(level)
    if machine.power_feed_a
      location = machine.power_feed_a
      while location do
        if location.level == level
          return location
        end
        location = location.parent
      end
    end
    nil
  end
end
