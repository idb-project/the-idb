class UrlLinker
  class << self
    def rt_ticket(id)
      href = IDB.config.rt.ticket_url % id.to_s
      %(<a href="#{href}">RT##{id}</a>)
    end

    def redmine_ticket(id)
      href = IDB.config.redmine.ticket_url % id.to_s
      %(<a href="#{href}">Redmine##{id}</a>)
    end
  end
end
