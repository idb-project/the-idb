class TicketService
    def initialize(ticket)
        @ticket = ticket
    end

    def send
        body = @ticket.format
        @ticket.ticket_id = 123
        @ticket.save!
    end

    def self.create_rt_ticket(queue, requestor, cc, subject, text)
        uri = URI(IDB.config.rt.create_ticket_url)
        uri.query = URI.encode_www_form({user: IDB.config.rt.user, password: IDB.config.rt.password })

        http = Net::HTTP.net(uri.host, uri.port)
        http.read_timeout = 5

        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = TicketService.encode_rt_ticket(queue, requestor, cc, subject, text)

        res = http.request(req)
    end

    def self.encode_rt_ticket(queue, requestor, cc, subject, text)
        lines = text.split("\n")
        lines_new = [lines[0]]
        lines[1..-1].each do |line|
            lines_new << " #{line}"
        end

        x = %q(id: new
Queue: %{queue}
Requestor: %{requestor}
Subject: %{subject}
Cc: %{cc}
Text: %{text}
)
        x % {queue: queue, requestor: requestor, cc: cc.join(","), subject: subject, text: lines_new.join("\n") }
    end
end