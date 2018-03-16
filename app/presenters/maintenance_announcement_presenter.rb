class MaintenanceAnnouncementPresenter < Keynote::Presenter
    presents :maintenance_announcement

    delegate :id, :date, :reason, :impact, to: :maintenance_announcement

    def ticket_links
        links = Array.new
        maintenance_announcement.maintenance_tickets.pluck(:ticket_id).each do |ticket_id|
            links << link_to("\##{ticket_id}", IDB.config.rt.ticket_url % ticket_id)
        end
        links.join(", ").html_safe
    end

    def owner_links
        owner_names = Set.new
        maintenance_announcement.owners.each do |owner|
            owner_names << link_to(owner.display_name, owner_path(owner))
        end
        owner_names.to_a.join(", ").html_safe
    end

    def machine_links
        links = ['<ul style="list-style-type: none; margin: 0;">']
        maintenance_announcement.machines.each do |machine|
            links << "<li>" + link_to(machine.fqdn, machine_path(machine)) + "</li>"
        end
        links << "</ul>"
        links.join(" ").html_safe
    end

    def template_link
        template = maintenance_announcement.maintenance_template
        if template
            return link_to(template.name, maintenance_template_path(template)).html_safe
        end
    end
end
