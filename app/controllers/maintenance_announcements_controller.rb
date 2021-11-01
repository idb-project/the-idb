class MaintenanceAnnouncementsController < ApplicationController
    autocomplete :maintenance_announcement, :email

    def index
        @maintenance_announcements = MaintenanceAnnouncement.where(preview: false).reverse
    end

    def show
        @maintenance_announcement = MaintenanceAnnouncement.find(params[:id])
    end

    def new
        # initialize variables for rendering new
        @machines = Machine.all
        @maintenance_templates = MaintenanceTemplate.all.order(:name)
        @selected_machines = Array.new
        @no_deadline = Array.new
        @no_contacts = Array.new
        @missing_vms = Array.new
        @begin_date = Time.zone.now
        @end_date = Time.zone.now + 1.hours
        @exceeded_deadlines = Array.new
        @missing_vms = Array.new
        @exceeded_deadlines = Array.new
        @ignore_vms = true

        # selected machines if we got back here from create. map them with to_i so we can use them as integers in the template.
        @selected_machines = Machine.where(id: params[:machine_ids])

        if params[:from]
            @old_announcement = MaintenanceAnnouncement.find(params[:from])
            @selected_machines = @old_announcement.machines
            @begin_date = @old_announcement.begin_date
            @end_date = @old_announcement.end_date
            @ignore_vms = @old_announcement.ignore_vms? || true
            @ignore_deadlines = @old_announcement.ignore_deadlines?

            # remove preview announcement
            if @old_announcement.preview
                @old_announcement.destroy
            end
        end
    end

    def create
        # initialize variables for rendering new
        @machines = Machine.all
        @maintenance_templates = MaintenanceTemplate.all.order(:name)
        @selected_machines = Array.new
        @no_contacts = Array.new
        @missing_vms = Array.new
        @begin_date = Time.zone.now
        @end_date = Time.zone.now
        @exceeded_deadlines = Array.new
        @ignore_deadlines = params[:ignore_deadlines]
        @ignore_vms = params[:ignore_vms]
        @maintenance_template_id = params[:maintenance_template_id]

        @no_maintenance_template = !MaintenanceTemplate.exists?(@maintenance_template_id)
        @email = params[:email].blank? ? nil : params[:email].delete(" ").gsub(";", ",")

        # get selected machines
        @selected_machines = Machine.where(id: params[:machine_ids])

        # check if all selected machines have a deadline set
        @no_deadline = deadline_exists(@selected_machines)

        # select all different owners
        owner_ids = Machine.select(:owner_id).where(id: params[:machine_ids]).group(:owner_id).pluck(:owner_id)
        @owners = Owner.where(id: owner_ids)

        # check if there are owners without announcement contact set
        @no_contacts = check_owner_contacts(@owners)

        # get all vms that belong to a selected machine but arent selected themselves
        @missing_vms = unselected_vms(@selected_machines)

        if params[:machine_ids].nil? || params[:machine_ids].empty?
          @machine_error = "No machines selected."
          return render :new
        end

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

        if  (not (@no_deadline.empty? or @ignore_deadlines == "1")) or
            (not (@no_contacts.empty? or @email)) or
            (not (@missing_vms.empty? or @ignore_vms == "1")) or
            (not (@exceeded_deadlines.empty? or @ignore_deadlines == "1")) or
            (@no_maintenance_template)
            return render :new
        end

        if !MaintenanceTemplate.exists?(params[:maintenance_template_id])
            flash.alert = "No templates found, please create one."
            return render :new
        end

        @announcement = MaintenanceAnnouncement.new(user: @current_user, begin_date: @begin_date, end_date: @end_date, maintenance_template_id: params[:maintenance_template_id], email: @email, ignore_vms: @ignore_vms, ignore_deadlines: @ignore_deadlines, preview: true)

        # create a ticket per owner
        @tickets = new_tickets(@announcement, @owners, @selected_machines)

        # save announcement and tickets in one transaction
        MaintenanceAnnouncement.transaction do
            @announcement.save!
            @tickets.each do |ticket|
                ticket.save!
            end
        end

        redirect_to preview_maintenance_announcement_path(@announcement)
    end

    def preview
        @announcement = MaintenanceAnnouncement.find(params[:id])
        @tickets = @announcement.maintenance_tickets
    
        render :preview
    end

    def submit
        @announcement = MaintenanceAnnouncement.find(params[:id])
        @announcement.custom_subject = params[:custom_subject]
        @announcement.custom_body = params[:custom_body]
        @tickets = @announcement.maintenance_tickets

        begin
          @tickets.each do |ticket|
              TicketService.send(ticket)
          end
          @announcement.preview = false
          @announcement.save!

          redirect_to maintenance_announcements_path
        rescue Exception, RuntimeError => e
          flash.alert = e.message
          return render :preview
        end
    end

    def cancel
        announcement = MaintenanceAnnouncement.find(params[:id])
        redirect_to edit_maintenance_announcement_path(announcement)
    end

    def edit
        @announcement = MaintenanceAnnouncement.find(params[:id])
        unless @announcement.preview
            flash.alert = "Can only edit unsend announcements"
            redirect_to maintenance_announcements_path
        end

        # initialize variables for rendering the form
        @machines = Machine.all
        @maintenance_templates = MaintenanceTemplate.all.order(:name)
        @selected_machines = Machine.joins(maintenance_tickets: :maintenance_announcement).where(maintenance_announcements: {id: @announcement.id})
        @begin_date = @announcement.begin_date
        @end_date = @announcement.end_date
        @ignore_deadlines = @announcement.ignore_deadlines
        @ignore_vms = @announcement.ignore_vms
        @maintenance_template_id = @announcement.maintenance_template
        @email = @announcement.email

        # initialize error arrays
        @no_deadline = Array.new
        @no_contacts = Array.new
        @missing_vms = Array.new
        @exceeded_deadlines = Array.new
        @missing_vms = Array.new

        render :edit
    end

    def update
        @announcement = MaintenanceAnnouncement.find(params[:id])
        unless @announcement.preview
            flash.alert = "Can only edit unsend announcements"
            redirect_to maintenance_announcements_path
        end

        # initialize variables for rendering new
        @machines = Machine.all
        @maintenance_templates = MaintenanceTemplate.all.order(:name)
        @selected_machines = Array.new
        @no_contacts = Array.new
        @missing_vms = Array.new
        @begin_date = Time.zone.now
        @end_date = Time.zone.now
        @exceeded_deadlines = Array.new
        @ignore_deadlines = params[:ignore_deadlines]
        @ignore_vms = params[:ignore_vms]
        @maintenance_template_id = params[:maintenance_template_id]

        @no_maintenance_template = !MaintenanceTemplate.exists?(@maintenance_template_id)
        @email = params[:email].blank? ? nil : params[:email].delete(" ").gsub(";", ",")

        # get selected machines
        @selected_machines = Machine.where(id: params[:machine_ids])

        # check if all selected machines have a deadline set
        @no_deadline = deadline_exists(@selected_machines)

        # select all different owners
        owner_ids = Machine.select(:owner_id).where(id: params[:machine_ids]).group(:owner_id).pluck(:owner_id)
        @owners = Owner.where(id: owner_ids)

        # check if there are owners without announcement contact set
        @no_contacts = check_owner_contacts(@owners)

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
            return render :edit
        end

        # get all machines where the deadline is exceeded
        @exceeded_deadlines = check_deadlines(@selected_machines, @begin_date)

        if  (not (@no_deadline.empty? or @ignore_deadlines == "1")) or
            (not (@no_contacts.empty? or @email)) or
            (not (@missing_vms.empty? or @ignore_vms == "1")) or
            (not (@exceeded_deadlines.empty? or @ignore_deadlines == "1")) or
            (@no_maintenance_template)
            return render :edit
        end

        if !MaintenanceTemplate.exists?(params[:maintenance_template_id])
            flash.alert = "No templates found, please create one."
            return render :edit
        end

        # update the announcement
        @announcement.user = @current_user
        @announcement.begin_date = @begin_date
        @announcement.end_date = @end_date
        @announcement.maintenance_template_id = params[:maintenance_template_id]
        @announcement.email = @email
        @announcement.ignore_vms = @ignore_vms
        @announcement.ignore_deadlines = @ignore_deadlines
        @announcement.preview = true
        
        # delete all old tickets for this announcement
        @announcement.maintenance_tickets.destroy_all

        # create a ticket per owner
        @tickets = new_tickets(@announcement, @owners, @selected_machines)

        # save announcement and tickets in one transaction
        MaintenanceAnnouncement.transaction do
            @announcement.save!
            @tickets.each do |ticket|
                ticket.save!
            end
        end

        render :preview
    end

    def autocomplete_maintenance_announcement_email
        render json: MaintenanceAnnouncement.where("email LIKE ?", "#{params[:term]}%").distinct.pluck(:email)
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
        if announcement.email
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
