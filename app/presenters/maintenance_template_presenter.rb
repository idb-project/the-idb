 class MaintenanceTemplatePresenter < Keynote::Presenter
    presents :maintenance_template

    delegate :id, :name, :template, to: :maintenance_template

    def announcement_links
        links = Array.new
        maintenance_template.maintenance_announcements.each do |announcement|
            links << link_to(announcement.id, announcement)
        end
        links.join(", ").html_safe
    end
end
