class MaintenanceAnnouncementPresenter < Keynote::Presenter
    presents :maintenance_announcement

    delegate :id, :user, :reason, :impact, :email, to: :maintenance_announcement

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

    def begin_date
        maintenance_announcement.begin_date.to_formatted_s(:db)
    end

    def end_date
        maintenance_announcement.end_date.to_formatted_s(:db)
    end

    def user_link
        unless maintenance_announcement.user
            return "unknown user"
        end
        user = k(maintenance_announcement.user)
        user.name_link
    end

    def comment
        TextileRenderer.render(maintenance_announcement.comment) if maintenance_announcement.comment
    end

    def short_comment
        unless maintenance_announcement.comment
            return ""
        end

        short = maintenance_announcement.comment
        if short.lines.size > 10
            short = short.lines[0..9].append("[…]").join
        end
        
        TextileRenderer.render(short)
    end
end
