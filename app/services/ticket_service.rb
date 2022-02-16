require 'net/http/post/multipart'

class TicketService
    def self.send(ticket)
        text = ticket.format_body
        subject = ticket.format_subject
	ical = ticket.format_ical
        queue = ticket.rt_queue
        requestor = IDB.config.rt.requestor
        owner = "nobody"
        owner = ticket.maintenance_announcement.user.rtname if ticket.maintenance_announcement.user.rtname

        begin
          # create ticket
          Rails.logger.info "Creating ticket"
          ticket_id = TicketService.create_rt_ticket(queue, requestor, subject, text, owner)
          Rails.logger.info "Ticket #{ticket_id} created"

          ticket.ticket_id = ticket_id
          ticket.save # save after each step

          # comment ticket to send announcement to real contact in bcc
          bcc = [ ticket.email ]
          Rails.logger.info "Replying ticket #{ticket_id}"
          TicketService.reply_rt_ticket(ticket_id, bcc, subject, text, ical)
          Rails.logger.info "Ticket replied"
          ticket.save

          # if we have an invitation_email, add another reply containing the ical-invitation
          unless ticket.invitation_email.blank?
              Rails.logger.info "Replying ticket #{ticket_id} with invitation"
              Rails.logger.info "Replying invitation to #{ticket.invitation_email}"
              ical_invitation = ticket.format_ical true
              TicketService.invitation_reply_rt_ticket(ticket_id, [ ticket.invitation_email ], subject, ical_invitation)
              Rails.logger.info "Invitation reply send"
          end

          ticket.save!
        rescue Exception => e
          raise e
        end
    end

    private

    def self.create_rt_ticket(queue, requestor, subject, text, owner)
        uri = self.build_create_uri

        res = Net::HTTP.post_form(uri, content: TicketService.encode_create_ticket(queue, requestor, subject, text, owner))
        if res.code != "200"
            Rails.logger.fatal "FATAL: RT ticket creation failed"
            Rails.logger.fatal res.code
            Rails.logger.fatal res.body
            raise Exception.new "RT ticket could not be created"
        end

        ticket_id = self.ticket_id(res.body)
        if not ticket_id
            Rails.logger.fatal "RT ticket could not be created, no ticket ID"
	    Rails.logger.fatal res.code
	    Rails.logger.fatal res.body
	    Rails.logger.fatal self.ticket_id(res_body)
            raise Exception.new "RT ticket could not be created, no ticket ID"
        end
        
        return ticket_id
    end

    def self.encode_create_ticket(queue, requestor, subject, text, owner)
        text = self.indent(text)

        x = %q(id: new
Owner: %{owner}
Queue: %{queue}
Requestor: %{requestor}
Subject: %{subject}
Text: %{text}
)
        x % {queue: queue, requestor: requestor, subject: subject, text: text, owner: owner }
    end

    def self.build_create_uri
        uri = URI(IDB.config.rt.create_ticket_url)
        uri.query = URI.encode_www_form({user: IDB.config.rt.user, pass: IDB.config.rt.password })
        uri
    end

    def self.reply_rt_ticket(ticket_id, bcc, subject, text, ical)
        uri = self.build_reply_uri(ticket_id)

	ical_io = UploadIO.new(StringIO.new(ical), "text/calendar", "wartungsarbeiten.ics")

	Net::HTTP.start(uri.host, uri.port, { :use_ssl => true } ) do |http|
            req = Net::HTTP::Post::Multipart.new(uri, { "content" => TicketService.encode_reply_ticket(ticket_id, bcc, subject, text), "attachment_1" => ical_io })
            res = http.request(req)
            if res.code != "200" 
                Rails.logger.fatal "FATAL: RT reply could not be created"
                Rails.logger.fatal res.code
                Rails.logger.fatal res.body
                raise Exception.new "RT ticket could not be replied"
	    end
	end
    end

    def self.encode_reply_ticket(ticket_id, bcc, subject, text)
        text = self.indent(text)

        x = %q(id: %{ticket_id}
Action: correspond
Bcc: %{bcc}
Subject: %{subject}
Attachment: wartungsarbeiten.ics
Text: %{text}
)
        x % {ticket_id: ticket_id, bcc: bcc.join(","), subject: subject, text: text }
    end

    def self.invitation_reply_rt_ticket(ticket_id, bcc, subject, ical)
        uri = self.build_reply_uri(ticket_id)
	res = Net::HTTP.post_form(uri, content: TicketService.encode_invitation_reply_ticket(ticket_id, bcc, subject, ical))
        if res.code != "200"
            Rails.logger.fatal "FATAL: RT invitation reply could not be created"
            Rails.logger.fatal res.code
            Rails.logger.fatal res.body
            raise Exception.new "RT ticket could not be replied"
        end
    end

    def self.encode_invitation_reply_ticket(ticket_id, bcc, subject, ical)
        text = self.indent(ical)

        x = %q(id: %{ticket_id}
Action: correspond
Content-Type: text/calendar; method=REQUEST; charset="UTF-8"
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

    def self.ticket_id(body)
        m = /# Ticket ([0-9]+) created\./.match(body)

        if m.nil?
            return nil
        elsif m.size < 2
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
