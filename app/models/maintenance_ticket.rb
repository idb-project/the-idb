require "icalendar/tzinfo"

class MaintenanceTicket < ApplicationRecord
  belongs_to :maintenance_announcement
  has_and_belongs_to_many :machines
  has_many :owners, :through => :machines

  def format_body
    announcement = maintenance_announcement
    template = announcement.maintenance_template
    template.format_body(template.format_params(self), announcement)
  end

  def format_subject
    announcement = maintenance_announcement
    template = announcement.maintenance_template
    template.format_subject(template.format_params(self), announcement)
  end

  def format_ical(invitation=false)
	announcement = maintenance_announcement
	template = announcement.maintenance_template

	zone = IDB.config.rt.zone
	dtstart = Icalendar::Values::DateOrDateTime.new(announcement.begin_date.change(zone: zone).to_formatted_s(:announcement_ical), 'tzid' => zone)
	dtend = Icalendar::Values::DateOrDateTime.new(announcement.end_date.change(zone: zone).to_formatted_s(:announcement_ical), 'tzid' => zone)

	cal = Icalendar::Calendar.new
	tz = TZInfo::Timezone.get zone
	cal.add_timezone(tz.ical_timezone DateTime.now) # use the current timezone. if we write 12:00 in the winter we still want it to be 12:00 in the summer, regardless of DST.

	cal.event do |e|
		e.dtstart = dtstart
		e.dtend = dtend
		e.summary = format_subject
		e.description = format_body
		if invitation
		    e.organizer = Icalendar::Values::CalAddress.new(IDB.config.rt.organizer)
		    unless self.invitation_email.empty? # just be sure nothing throws here
                        e.attendee = Icalendar::Values::CalAddress.new(self.invitation_email, ROLE: "REQ-PARTICIPANT", PARTSTAT: "NEEDS-ACTION", RSVP: "TRUE")
                    end
		end
	end

	if invitation
		cal.ip_method = "REQUEST"
	else
		cal.publish
	end

	cal.to_ical
  end

  # def format_machines_fqdns
  #   machines.pluck(:fqdn).join(", ")
  # end

  # we only have one owner
  def owner
    owners.group(:id).first
  end

  def rt_queue
    if owner && !owner.rt_queue.blank?
        owner.rt_queue
    else
      IDB.config.rt.queue
    end
  end

  # get the email address, either the owners or the one set in the announcement
  def email
    if maintenance_announcement.email
      return maintenance_announcement.email
    end

    return owner.announcement_contact
  end

  def invitation_email
    if maintenance_announcement.maintenance_template.invitation_contact
      return maintenance_announcement.maintenance_template.invitation_contact
    end
  end

  private

end
