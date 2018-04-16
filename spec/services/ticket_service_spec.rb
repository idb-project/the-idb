require 'spec_helper'

describe TicketService do
  describe 'encode_rt_ticket' do
    it 'encodes data to be usable as content in a RT API request' do
      queue = "Queue"
      requestor = "Requestor"
      subject = "Subject"
      cc = ["test@example.com"]
      text = %q(multi
line
string)

      want_text = %q(multi
 line
 string)

      x = TicketService.encode_rt_ticket(queue, requestor, cc, subject, text)
      want = %Q(id: new
Queue: #{queue}
Requestor: #{requestor}
Subject: #{subject}
Cc: #{cc.join(",")}
Text: #{want_text}
)

      expect(x).to eq(want)
    end
  end

  describe 'indent' do
    it 'indents every but the first line with a space' do
      text_in = %q(multi
line
string)

      want = %q(multi
 line
 string)

      text_out = TicketService.indent(text_in)

      expect(text_out).to eq(want)
    end
  end

  describe 'ticket_id' do
    it 'extracts the rt ticket id as integer from a body' do
      body=%q(# Ticket 123 created.)

      nr = TicketService.ticket_id(body)

      expect(nr).to eq(123)
    end
  end

  describe 'build_uri' do
    it 'builds the request uri to create a new ticket' do
      IDB.config.rt.create_ticket_url = "http://support.example.com"
      IDB.config.rt.user = "user"
      IDB.config.rt.password = "password"

      uri = TicketService.build_uri

      expect(uri.to_s).to eq("#{IDB.config.rt.create_ticket_url}?user=#{IDB.config.rt.user}&pass=#{IDB.config.rt.password}")
    end
  end

  describe 'build_request' do
    it 'builds a request to create a new ticket' do
      IDB.config.rt.create_ticket_url = "http://support.example.com"
      IDB.config.rt.user = "user"
      IDB.config.rt.password = "password"

      queue = "Queue"
      requestor = "Requestor"
      subject = "Subject"
      cc = ["test@example.com"]
      text = %q(multi
line
string
)

      want_text = %q(multi
 line
 string
)      

      want = %Q(id: new
Queue: #{queue}
Requestor: #{requestor}
Subject: #{subject}
Cc: #{cc[0]}
Text: #{want_text})
      
      req = TicketService.build_request(TicketService.build_uri, queue, requestor, cc, subject, text)

      dec = URI.decode_www_form(req.body)

      expect(dec[0][0]).to eq("content")
      expect(dec[0][1]).to eq(want)
    end
  end
end
