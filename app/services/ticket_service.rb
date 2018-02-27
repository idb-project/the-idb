class TicketService
    def initialize(ticket)
        @ticket = ticket
    end

    def send
        @ticket.ticket_id = 123
        @ticket.save!
    end
end