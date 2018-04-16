class MaintenanceTemplate < ApplicationRecord
    has_many :maintenance_announcements

    def format_subject(params)
        subject % params
    end

    def format_body(params)
        body % params
    end
end
