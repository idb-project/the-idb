class LocationPresenter < Keynote::Presenter
  presents :location

  delegate :id, :name, :location_id, :description, :self_and_ancestors, :location_name,
           to: :location

  def location_link
    return "" unless location
    names = Array.new()
    location.self_and_ancestors.to_a.reverse.each do |item|
      names.push(link_to(item.name, item))
    end
    names.join(" → ").html_safe
  end
end
