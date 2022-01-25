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

  def format_ical
	announcement = maintenance_announcement
	template = announcement.maintenance_template
	cal = Icalendar::Calendar.new
	cal.event do |e|
		e.dtstart = announcement.begin_date.to_formatted_s(:announcement_ical)
		e.dtend = announcement.end_date.to_formatted_s(:announcement_ical)
		e.summary = format_subject
		e.description = format_body
	end
	cal.publish # cal.ip_method = "REQUEST"
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

  private

end
