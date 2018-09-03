require 'spec_helper'

RSpec.describe MaintenanceAnnouncementsController, type: :controller do
    before(:each) do
        # stub sending of tickets
        allow(TicketService).to receive(:send).and_return(true)
        x = Time.now
        @begin_date = Time.zone.local(x.year,x.month,x.day,x.hour,x.min,0)
        @end_date = @begin_date + 1.days
        @date_params = {
            "begin_date(1i)": @begin_date.year,
            "begin_date(2i)": @begin_date.month,
            "begin_date(3i)": @begin_date.day,
            "begin_date(4i)": @begin_date.hour,
            "begin_date(5i)": @begin_date.min,
            "end_date(1i)": @end_date.year,
            "end_date(2i)": @end_date.month,
            "end_date(3i)": @end_date.day,
            "end_date(4i)": @end_date.hour,
            "end_date(5i)": @end_date.min,
        }
        @template = FactoryGirl.create(:maintenance_template)
        @current_user = FactoryGirl.create :user
        @owner0 = FactoryGirl.create(:owner, users: [@current_user], announcement_contact: "owner0@example.org")
        @owner1 = FactoryGirl.create(:owner, users: [@current_user], announcement_contact: "owner1@example.org")
        allow(User).to receive(:current).and_return(@current_user)
        controller.session[:user_id] = @current_user.id
    end

    describe "POST create, successful" do
        before(:each) do
            @t = Time.now
            @m0 = FactoryGirl.create(:machine, owner: @owner0, announcement_deadline: 0)
            @m1 = FactoryGirl.create(:machine, owner: @owner0, announcement_deadline: 0)
            @m2 = FactoryGirl.create(:machine, owner: @owner1, announcement_deadline: 0)
            @m3 = FactoryGirl.create(:machine, owner: @owner1, announcement_deadline: 0)
        end
    
        it "creates a new maintenance announcement affecting a single owner" do
            post :create, params: { maintenance_announcement: @date_params, reason: "reason", impact: "impact", maintenance_template_id: @template.id, machine_ids: [ @m0.id, @m1.id ] }
            expect(MaintenanceAnnouncement.last.begin_date <=> @begin_date).to eq(0)
            expect(MaintenanceAnnouncement.last.end_date <=> @end_date).to eq(0)
            expect(MaintenanceAnnouncement.last.reason).to eq("reason")
            expect(MaintenanceAnnouncement.last.impact).to eq("impact")
            expect(MaintenanceTicket.last.machines.size).to eq(2)
            expect(MaintenanceTicket.last.machines.first).to eq(@m0)
            expect(MaintenanceTicket.last.machines.second).to eq(@m1)
        end

        it "creates a new maintenance announcement affecting multiple owners" do
            post :create, params: {maintenance_announcement: @date_params, reason: "reason", impact: "impact", maintenance_template_id: @template.id, machine_ids: [ @m0.id, @m1.id, @m2.id, @m3.id ] }
            expect(MaintenanceAnnouncement.last.begin_date <=> @begin_date).to eq(0)
            expect(MaintenanceAnnouncement.last.end_date <=> @end_date).to eq(0)
            expect(MaintenanceAnnouncement.last.reason).to eq("reason")
            expect(MaintenanceAnnouncement.last.impact).to eq("impact")
            expect(MaintenanceTicket.first.machines.size).to eq(2)
            expect(MaintenanceTicket.first.machines.first).to eq(@m0)
            expect(MaintenanceTicket.first.machines.second).to eq(@m1)
            expect(MaintenanceTicket.second.machines.size).to eq(2)
            expect(MaintenanceTicket.second.machines.first).to eq(@m2)
            expect(MaintenanceTicket.second.machines.second).to eq(@m3)
        end
    end

    describe "POST create, unselected VMs and not ignoring" do
        before(:each) do
            @m0 = FactoryGirl.create(:machine, owner: @owner0)
            @m1 = FactoryGirl.create(:virtual_machine, owner: @owner0, vmhost: @m0.fqdn)
        end
    
        it "renders new" do
            post :create, params: {maintenance_announcement: @date_params, reason: "reason", impact: "impact", maintenance_template_id: @template.id, machine_ids: [ @m0.id ] }
            expect(response).to render_template("maintenance_announcements/new")
        end
    end

    describe "POST create, unselected VMs and ignoring" do
        before(:each) do
            @m0 = FactoryGirl.create(:machine, owner: @owner0, announcement_deadline: 0)
            @vm0 = FactoryGirl.create(:virtual_machine, owner: @owner0, vmhost: @m0.fqdn, announcement_deadline: 0)
            @vm1 = FactoryGirl.create(:virtual_machine, owner: @owner0, vmhost: @m0.fqdn, announcement_deadline: 0)
        end
    
        it "creates a new maintenance announcement" do
            post :create, params: {maintenance_announcement: @date_params, reason: "reason", impact: "impact", maintenance_template_id: @template.id, machine_ids: [ @m0.id, @vm0.id ], ignore_vms: true}
            expect(MaintenanceAnnouncement.last.begin_date <=> @begin_date).to eq(0)
            expect(MaintenanceAnnouncement.last.end_date <=> @end_date).to eq(0)
            expect(MaintenanceAnnouncement.last.reason).to eq("reason")
            expect(MaintenanceAnnouncement.last.impact).to eq("impact")
            expect(MaintenanceTicket.last.machines.size).to eq(2)
            expect(MaintenanceTicket.last.machines.first).to eq(@m0)
        end
    end

    describe "POST create, deadline exceeded" do
        before(:each) do
            x = Time.now
            @begin_date = Time.zone.local(x.year,x.month,x.day,x.hour,x.min,0)
            @end_date = @begin_date + 1.days
            @date_params = {
                "begin_date(1i)": @begin_date.year,
                "begin_date(2i)": @begin_date.month,
                "begin_date(3i)": @begin_date.day,
                "begin_date(4i)": @begin_date.hour,
                "begin_date(5i)": @begin_date.min,
                "end_date(1i)": @end_date.year,
                "end_date(2i)": @end_date.month,
                "end_date(3i)": @end_date.day,
                "end_date(4i)": @end_date.hour,
                "end_date(5i)": @end_date.min,
            }
            @m0 = FactoryGirl.create(:machine, owner: @owner0, announcement_deadline: 7)
        end
    
        it "renders new" do
            post :create, params: {maintenance_announcement: @date_params, reason: "reason", impact: "impact", maintenance_template_id: @template.id, machine_ids: [ @m0.id ] }
            expect(response).to render_template("maintenance_announcements/new")
        end
    end

    describe "POST create, deadline exceeded and ignoring" do
        before(:each) do
            x = Time.now
            @begin_date = Time.zone.local(x.year,x.month,x.day,x.hour,x.min,0)
            @end_date = @begin_date + 1.days
            @date_params = {
                "begin_date(1i)": @begin_date.year,
                "begin_date(2i)": @begin_date.month,
                "begin_date(3i)": @begin_date.day,
                "begin_date(4i)": @begin_date.hour,
                "begin_date(5i)": @begin_date.min,
                "end_date(1i)": @end_date.year,
                "end_date(2i)": @end_date.month,
                "end_date(3i)": @end_date.day,
                "end_date(4i)": @end_date.hour,
                "end_date(5i)": @end_date.min,
            }
            @m0 = FactoryGirl.create(:machine, owner: @owner0, announcement_deadline: 7)
        end
    
        it "creates a new maintenance announcement" do
            post :create, params: {maintenance_announcement: @date_params, reason: "reason", impact: "impact", maintenance_template_id: @template.id, machine_ids: [ @m0.id ], ignore_deadlines: true }
            expect(MaintenanceAnnouncement.last.begin_date <=> @begin_date).to eq(0)
            expect(MaintenanceAnnouncement.last.reason).to eq("reason")
            expect(MaintenanceAnnouncement.last.impact).to eq("impact")
            expect(MaintenanceTicket.last.machines.size).to eq(1)
            expect(MaintenanceTicket.last.machines.first).to eq(@m0)
        end
    end

    describe "POST create, deadline not exceeded" do
        before(:each) do
            x = Time.now
            @begin_date = Time.zone.local(x.year,x.month,x.day,x.hour,x.min,0) + 14.days
            @end_date = @begin_date + 1.days
            @date_params = {
                "begin_date(1i)": @begin_date.year,
                "begin_date(2i)": @begin_date.month,
                "begin_date(3i)": @begin_date.day,
                "begin_date(4i)": @begin_date.hour,
                "begin_date(5i)": @begin_date.min,
                "end_date(1i)": @end_date.year,
                "end_date(2i)": @end_date.month,
                "end_date(3i)": @end_date.day,
                "end_date(4i)": @end_date.hour,
                "end_date(5i)": @end_date.min,
            }
            @m0 = FactoryGirl.create(:machine, owner: @owner0, announcement_deadline: 7)
        end
    
        it "creates a new maintenance announcement" do
            post :create, params: {maintenance_announcement: @date_params, reason: "reason", impact: "impact", maintenance_template_id: @template.id, machine_ids: [ @m0.id ] }
            expect(MaintenanceAnnouncement.last.begin_date <=> @begin_date).to eq(0)
            expect(MaintenanceAnnouncement.last.reason).to eq("reason")
            expect(MaintenanceAnnouncement.last.impact).to eq("impact")
            expect(MaintenanceTicket.last.machines.size).to eq(1)
            expect(MaintenanceTicket.last.machines.first).to eq(@m0)
        end
    end

    describe "POST create, one owner has no contact" do
        before(:each) do
            @owner_no_contact = FactoryGirl.create(:owner, users: [@current_user])
            @m0 = FactoryGirl.create(:machine, owner: @owner0)
            @m1 = FactoryGirl.create(:virtual_machine, owner: @owner_no_contact, vmhost: @m0.fqdn)
        end
    
        it "renders new" do
            post :create, params: {maintenance_announcement: @date_params, reason: "reason", impact: "impact", maintenance_template_id: @template.id, machine_ids: [ @m0.id, @m1.id ] }
            expect(response).to render_template("maintenance_announcements/new")
        end
    end

    describe "POST create, all owners have contact" do
        before(:each) do
            @m0 = FactoryGirl.create(:machine, owner: @owner0, announcement_deadline: 0)
            @m1 = FactoryGirl.create(:virtual_machine, owner: @owner1, vmhost: @m0.fqdn, announcement_deadline: 0)
        end
    
        it "creates a new maintenance announcement" do
            post :create, params: {maintenance_announcement: @date_params, reason: "reason", impact: "impact", maintenance_template_id: @template.id, machine_ids: [ @m0.id, @m1.id ] }
            expect(MaintenanceAnnouncement.last.begin_date <=> @begin_date).to eq(0)
            expect(MaintenanceAnnouncement.last.end_date <=> @end_date).to eq(0)
            expect(MaintenanceAnnouncement.last.reason).to eq("reason")
            expect(MaintenanceAnnouncement.last.impact).to eq("impact")
            expect(MaintenanceTicket.first.machines.size).to eq(1)
            expect(MaintenanceTicket.first.machines.first).to eq(@m0)
            expect(MaintenanceTicket.last.machines.size).to eq(1)
            expect(MaintenanceTicket.last.machines.first).to eq(@m1)
        end
    end

    describe "check_owner_contacts" do
        it "filters owners with contacts, returning every owner without contact" do
            owner0 = FactoryGirl.create(:owner, announcement_contact: "test@example.com")
            owner1 = FactoryGirl.create(:owner, announcement_contact: "")
            owner2 = FactoryGirl.create(:owner)

            c = MaintenanceAnnouncementsController.new
            no_contacts = c.send(:check_owner_contacts, [owner0, owner1, owner2])
            expect(no_contacts.size).to eq(2)
            expect(no_contacts[0]).to eq(owner1)
            expect(no_contacts[1]).to eq(owner2)
        end
    end

    describe "deadline_exists" do
        it "filters machines with deadlines, returning machines without deadlines" do
            m0 = FactoryGirl.create(:machine, announcement_deadline: 14)
            m1 = FactoryGirl.create(:machine, announcement_deadline: nil)

            c = MaintenanceAnnouncementsController.new
            no_deadline = c.send(:deadline_exists, [m0, m1])
            expect(no_deadline.size).to eq(1)
            expect(no_deadline[0]).to eq(m1)
        end
    end
end
