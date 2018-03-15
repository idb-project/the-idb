class MaintenanceTemplate < ApplicationRecord
    has_many :maintenance_announcements

    def format(params)
        template % params
    end
end
