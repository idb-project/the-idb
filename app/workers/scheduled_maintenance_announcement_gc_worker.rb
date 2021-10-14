class ScheduledMaintenanceAnnouncementGCWorker
	include Sidekiq::Worker
  
	def perform
	  MaintenanceAnnouncement.where("preview = true AND created_at < ?", Time.now - 1.day).each do |announcement|
		  MaintenanceTicket.where(maintenance_announcement: announcement).destroy_all
		    announcement.destroy
	    end
	  end
  end
  
