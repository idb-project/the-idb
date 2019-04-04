class TicketService
    def self.send(ticket)
        text = ticket.format_body
        subject = ticket.format_subject
        queue = IDB.config.rt.queue
        requestor = IDB.config.rt.requestor

        # create ticket
        ticket_id = TicketService.create_rt_ticket(queue, requestor, subject, text)
        ticket.ticket_id = ticket_id

        # comment ticket to send announcement to real contact in bcc
        bcc = [ ticket.email ]
        TicketService.reply_rt_ticket(ticket_id, bcc, subject, text)

        ticket.save!
    end

    private

    def self.create_rt_ticket(queue, requestor, subject, text)
        uri = self.build_create_uri
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 5

        req = self.build_create_request(uri, queue, requestor, subject, text)
       
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

    def self.encode_create_ticket(queue, requestor, subject, text)
        text = self.indent(text)

        x = %q(id: new
Queue: %{queue}
Requestor: %{requestor}
Subject: %{subject}
Text: %{text}
)
        x % {queue: queue, requestor: requestor, subject: subject, text: text }
    end

    def self.build_create_uri
        uri = URI(IDB.config.rt.create_ticket_url)
        uri.query = URI.encode_www_form({user: IDB.config.rt.user, pass: IDB.config.rt.password })
        uri
    end

    def self.build_create_request(uri, queue, requestor, subject, text)
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = URI.encode_www_form({content: TicketService.encode_create_ticket(queue, requestor, subject, text)})
        req
    end

    def self.reply_rt_ticket(ticket_id, bcc, subject, text)
        uri = self.build_reply_uri(ticket_id)
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 5

        req = self.build_reply_request(uri, ticket_id, bcc, subject, text)

        res = http.request(req)
        
        if res.code != "200" 
            return nil
        end
    end

    def self.encode_reply_ticket(ticket_id, bcc, subject, text)
        text = self.indent(text)

        x = %q(id: %{ticket_id}
Action: correspond
Bcc: %{bcc}
Subject: %{subject}
Text: %{text}
)
        x % {ticket_id: ticket_id, bcc: bcc.join(","), subject: subject, text: text }
    end

    def self.build_reply_uri(ticket_id)
        uri = URI(IDB.config.rt.reply_ticket_url % ticket_id)
        uri.query = URI.encode_www_form({user: IDB.config.rt.user, pass: IDB.config.rt.password })
        uri
    end

    def self.build_reply_request(uri, ticket_id, bcc, subject, text)
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = URI.encode_www_form({content: TicketService.encode_reply_ticket(ticket_id, bcc, subject, text)})
        req
    end

    def self.ticket_id(body)
        m = /# Ticket ([0-9]+) created\./.match(body)
        
        if m.size < 2
            return nil
        end

        m[1].to_i
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
end
