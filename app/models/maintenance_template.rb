class MaintenanceTemplate < ApplicationRecord
    acts_as_paranoid if IDB.config.modules.softdelete

    has_many :maintenance_announcements

    validate :validate_placeholders

    # this hash defines the valid placeholders, and the way the raw values are formatted
    @@valid_placeholders = {
        begin_date: proc {|x| x.maintenance_announcement.begin_date.to_formatted_s(:announcement_date)},
        end_date: proc {|x| x.maintenance_announcement.end_date.to_formatted_s(:announcement_date)},
        begin_time: proc {|x| x.maintenance_announcement.begin_date.to_formatted_s(:announcement_time)},
        end_time: proc {|x| x.maintenance_announcement.end_date.to_formatted_s(:announcement_time)},
        begin_full: proc {|x| x.maintenance_announcement.begin_date.to_formatted_s(:announcement_full)},
        end_full: proc {|x| x.maintenance_announcement.end_date.to_formatted_s(:announcement_full)},
        machines: proc {|x| x.machines.pluck(:fqdn).join("\n") },
        user: proc {|x| x.maintenance_announcement.user.display_name }
    }

    def format_subject(params)
        subject % params
    end

    def format_body(params)
        body % params
    end

    def format_params(ticket)
        out = {}

        @@valid_placeholders.each do |k,v|
            out[k] = v.call(ticket)
        end

        out
    end

    def validate_placeholders
        begin
            subject % @@valid_placeholders
        rescue
            errors.add(:subject, "subject contains invalid placeholder")
        end

        begin
            body % @@valid_placeholders
        rescue
            errors.add(:body, "subject contains invalid placeholder")
        end
    end
end
