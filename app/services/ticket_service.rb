class TicketService
    def self.send(ticket)
        text = ticket.format
        queue = IDB.config.rt.queue
        requestor = IDB.config.rt.requestor
        cc = ["schuller@bytemine.net"]
        ticket_id = TicketService.create_rt_ticket(queue, requestor, cc, "Test Ticket", text)
        ticket.ticket_id = ticket_id
        ticket.save!
    end

    def self.create_rt_ticket(queue, requestor, cc, subject, text)
        uri = URI(IDB.config.rt.create_ticket_url)
        uri.query = URI.encode_www_form({user: IDB.config.rt.user, pass: IDB.config.rt.password })
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 5

        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = URI.encode_www_form({content: TicketService.encode_rt_ticket(queue, requestor, cc, subject, text)})

       
        res = http.request(req)
        
        m = /# Ticket ([0-9]+) created\./.match(res.body)
        
        if res.code != "200" or m.size < 2
            return nil
        end
        
        return m[1].to_i
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
