class MaintenanceAnnouncementsController < ApplicationController
    def index
        @maintenance_announcements = MaintenanceAnnouncement.all
    end

    def show
    end

    def new
        @machines = Machine.all
        @maintenance_templates = MaintenanceTemplate.all

        # selected machines if we got back here from create. map them with to_i so we can use them as integers in the template.
        @selected_machines = Machine.where(id: params[:machine_ids])

        @missing_vms = Array.new
        @exceeded_deadlines = Array.new
        @date = Time.now
    end

    def create
        # get selected machines
        @selected_machines = Machine.where(id: params[:machine_ids])

        # get all vms that belong to a selected machine but arent selected themselves
        @missing_vms = unselected_vms(@selected_machines)

        begin
            @date = Time.strptime(params[:date], "%Y-%m-%d")
        rescue
            flash.error = "Invalid date"
            @machines = Machine.all
            @maintenance_templates = MaintenanceTemplate.all
            return render :new
        end

        # get all machines where the deadline is exceeded
        @exceeded_deadlines = check_deadlines(@selected_machines, @date)

        if not @missing_vms.empty? and not params[:ignore_vms]
            # new needs all machines to render the table
            @machines = Machine.all
            @maintenance_templates = MaintenanceTemplate.all
            return render :new
        end

        if not @exceeded_deadlines.empty? and not params[:ignore_deadlines]
            @machines = Machine.all
            @maintenance_templates = MaintenanceTemplate.all
            return render :new
        end

        # select all different owners
        owner_ids = Machine.select(:owner_id).where(id: params[:machine_ids]).group(:owner_id).pluck(:owner_id)
        owners = Owner.where(id: owner_ids)

        announcement = MaintenanceAnnouncement.new(date: params[:date], reason: params[:reason], impact: params[:impact], maintenance_template_id: params[:maintenance_template_id])

        # create a ticket per owner
        tickets = new_tickets(announcement, owners, @selected_machines)

        # save announcement and tickets in one transaction
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

        redirect_to maintenance_announcements_path
    end

    private

    # check if deadlines of machines are held
    def check_deadlines(machines, date, now = Time.now)
        exceeded = []
        machines.each do |machine|
            # no deadline set in the machine, ignore it
            next unless machine.announcement_deadline



            # now - date is fewer seconds than the deadline
            if date - now < machine.announcement_deadline_seconds
                exceeded << machine
            end
        end
        exceeded
    end

    # check if vms hosted on machines are present in machines
    def unselected_vms(machines)
        unselected = []
        vms = VirtualMachine.hosted_on(machines)
        vms.each do |vm|
            if not machines.include?(vm)
                unselected << vm
            end
        end
        unselected
    end

    def new_tickets(announcement, owners, machines)
        tickets = []
        owners.each do |owner|
            # select all machines of this owner which are selected as affected
            owner_machines = Machine.where(owner: owner.id, id: machines.pluck(:id))
            tickets << MaintenanceTicket.new(maintenance_announcement: announcement, machines: owner_machines)
        end

        return tickets
    end
end
