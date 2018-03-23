class TicketService
    def self.send(ticket)
        text = ticket.format_body
        subject = ticket.format_subject
        queue = IDB.config.rt.queue
        requestor = IDB.config.rt.requestor
        cc = ticket.owner.announcement_contact
        ticket_id = TicketService.create_rt_ticket(queue, requestor, cc, subject, text)
        ticket.ticket_id = ticket_id
        ticket.save!
    end

    private

    def self.create_rt_ticket(queue, requestor, cc, subject, text)
        uri = self.build_uri
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 5

        req = self.build_request(uri, queue, requestor, cc, subject, text)
       
        res = http.request(req)
        
        if res.code != "200" 
            return nil
        end

        ticket_id = self.ticket_id(res.body)
        if not ticket_id
            return nil
        end
        
        return ticket_id
    end

    def self.encode_rt_ticket(queue, requestor, cc, subject, text)
        text = self.indent(text)

        x = %q(id: new
Queue: %{queue}
Requestor: %{requestor}
Subject: %{subject}
Cc: %{cc}
Text: %{text}
)
        x % {queue: queue, requestor: requestor, cc: cc.join(","), subject: subject, text: text }
    end

    # RT wants every line except for the first one to be indented with one space
    def self.indent(text)
        lines = text.split("\n")
        lines_new = [lines[0]]
        lines[1..-1].each do |line|
            lines_new << " #{line}"
        end
        lines_new.join("\n")
    end

    def self.build_uri
        uri = URI(IDB.config.rt.create_ticket_url)
        uri.query = URI.encode_www_form({user: IDB.config.rt.user, pass: IDB.config.rt.password })
        uri
    end

    def self.build_request(uri, queue, requestor, cc, subject, text)
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = URI.encode_www_form({content: TicketService.encode_rt_ticket(queue, requestor, cc, subject, text)})
        req
    end

    def self.ticket_id(body)
        m = /# Ticket ([0-9]+) created\./.match(body)
        
        if m.size < 2
            return nil
        end

        m[1].to_i
    end
end
