class MaintenanceAnnouncementsController < ApplicationController
    autocomplete :maintenance_announcement, :email

    def index
        @maintenance_announcements = MaintenanceAnnouncement.all
    end

    def show
        @maintenance_announcement = MaintenanceAnnouncement.find(params[:id])
    end

    def new
        # initialize variables for rendering new
        @machines = Machine.all
        @maintenance_templates = MaintenanceTemplate.all
        @selected_machines = Array.new
        @no_deadline = Array.new
        @no_contacts = Array.new
        @missing_vms = Array.new
        @begin_date = Time.zone.now
        @end_date = Time.zone.now
        @exceeded_deadlines = Array.new

        # selected machines if we got back here from create. map them with to_i so we can use them as integers in the template.
        @selected_machines = Machine.where(id: params[:machine_ids])

        @missing_vms = Array.new
        @exceeded_deadlines = Array.new
    end

    def create
        # initialize variables for rendering new
        @machines = Machine.all
        @maintenance_templates = MaintenanceTemplate.all
        @selected_machines = Array.new
        @no_contacts = Array.new
        @missing_vms = Array.new
        @begin_date = Time.zone.now
        @end_date = Time.zone.now
        @exceeded_deadlines = Array.new

        @no_maintenance_template = !MaintenanceTemplate.exists?(params[:maintenance_template_id])
        @email = params[:email] == "" ? nil : params[:email]

        # get selected machines
        @selected_machines = Machine.where(id: params[:machine_ids])

        # check if all selected machines have a deadline set
        @no_deadline = deadline_exists(@selected_machines)

        # select all different owners
        owner_ids = Machine.select(:owner_id).where(id: params[:machine_ids]).group(:owner_id).pluck(:owner_id)
        owners = Owner.where(id: owner_ids)

        # check if there are owners without announcement contact set
        @no_contacts = check_owner_contacts(owners)

        # get all vms that belong to a selected machine but arent selected themselves
        @missing_vms = unselected_vms(@selected_machines)

        # handle the time parsing, as it is likely to raise an exception
        begin
            ma = params[:maintenance_announcement]
            # use Time.zone.local to be aware of timezones.
            @begin_date = Time.zone.local(ma["begin_date(1i)"],ma["begin_date(2i)"],ma["begin_date(3i)"],ma["begin_date(4i)"],ma["begin_date(5i)"],0)
            @end_date = Time.zone.local(ma["end_date(1i)"],ma["end_date(2i)"],ma["end_date(3i)"],ma["end_date(4i)"],ma["end_date(5i)"],0)
            if not (@begin_date <=> @end_date) == -1
                raise "End date must be after begin date!"
            end
        rescue Exception => e
            @date_error = e.message
            return render :new
        end

        # get all machines where the deadline is exceeded
        @exceeded_deadlines = check_deadlines(@selected_machines, @begin_date)

        if (not @no_deadline.empty?) or (not @no_contacts.empty?) or (not @missing_vms.empty? and not params[:ignore_vms] == "true") or (not @exceeded_deadlines.empty? and not params[:ignore_deadlines] == "true") or (@no_maintenance_template)
            return render :new
        end

        if !MaintenanceTemplate.exists?(params[:maintenance_template_id])
            flash.alert = "No templates found, please create one."
            return render :new
        end

        announcement = MaintenanceAnnouncement.new(user: @current_user, begin_date: @begin_date, end_date: @end_date, reason: params[:reason], impact: params[:impact], maintenance_template_id: params[:maintenance_template_id], email: @email)

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
            TicketService.send(ticket)
        end

        redirect_to maintenance_announcements_path
    end

    def autocomplete_ma_email
        render json: MaintenanceAnnouncement.where("email LIKE ?", params[:term]).pluck("DISTINCT email")
    end

    private

    # check if every owner has a contact set
    def check_owner_contacts(owners)
        no_contacts = []
        owners.each do |owner|
            if owner.announcement_contact.blank?
                no_contacts << owner
            end
        end
        no_contacts
    end

    def deadline_exists(machines)
        no_deadline = []
        machines.each do |machine|
            next if machine.announcement_deadline

            no_deadline << machine
        end
        no_deadline
    end

    # check if deadlines of machines are held
    def check_deadlines(machines, date, now = Time.zone.now)
        exceeded = []
        machines.each do |machine|
            # no deadline set in the machine, ignore it
            next unless machine.announcement_deadline

            # now - date is fewer seconds than the deadline
            if (date - now < machine.announcement_deadline_seconds) or (date <=> now) == -1
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

        # if a email override is used, only create one ticket
        if announcement.email != ""
            tickets << MaintenanceTicket.new(maintenance_announcement: announcement, machines: machines)
            return tickets
        end

        owners.each do |owner|
            # select all machines of this owner which are selected as affected
            owner_machines = Machine.where(owner: owner.id, id: machines.pluck(:id))
            tickets << MaintenanceTicket.new(maintenance_announcement: announcement, machines: owner_machines)
        end

        return tickets
    end
end
