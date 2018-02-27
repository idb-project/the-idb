class MaintenanceAnnouncementsController < ApplicationController
    def index
    end

    def show
    end

    def new
    end

    def create
        # select all different owners
        owner_ids = Machine.select(:owner_id).where(id: params[:machine_ids]).group(:owner_id).pluck(:owner_id)

        announcement = MaintenanceAnnouncement.new(params.require(:maintenance_announcement).permit(:date, :reason, :impact, :maintenance_template_id))

        # create a ticket per owner
        tickets = new_tickets(announcement, owner_ids, params[:machine_ids])

        # save announcement and tickets
        MaintenanceAnnouncement.transaction do
            announcement.save!
            tickets.each do |ticket|
                ticket.save!
            end
        end

        # try to send each ticket
        tickets.each do |ticket|
            puts "Send ticket for #{ticket.machines.pluck(:id)}"
            TicketService.new(ticket).send
            puts "Ticket send as: #{ticket.ticket_id}"
        end
    end

    private

    def new_tickets(announcement, owner_ids, machine_ids)
        tickets = []
        owner_ids.each do |owner_id|
            # select all machines of this owner which are selected as affected
            owner_machines = Machine.where(owner_id: owner_id, id: machine_ids)
            tickets << MaintenanceTicket.new(maintenance_announcement: announcement, machines: owner_machines)
        end

        return tickets
    end
end
