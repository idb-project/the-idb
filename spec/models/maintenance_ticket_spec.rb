require 'spec_helper'

RSpec.describe MaintenanceTicket, type: :model do
  before(:each) do
    @current_user = FactoryBot.create :user
    allow(User).to receive(:current).and_return(@current_user)

    @owner0 = FactoryBot.create(:owner, users: [@current_user], announcement_contact: "owner0@example.org")

    @m0 = FactoryBot.create(:machine, owner: @owner0, announcement_deadline: 0)
    @m1 = FactoryBot.create(:machine, owner: @owner0, announcement_deadline: 0)

    x = Time.now
    @begin_date = Time.zone.local(x.year,x.month,x.day,x.hour,x.min,0)
    @end_date = @begin_date + 1.days
    @template = FactoryBot.create(:maintenance_template)
    @template.body = %q#%{begin_date} %{end_date} %{begin_time} %{end_time} %{begin_full} %{end_full} %{machines} %{user}#
    @template.subject = @template.body
    @announcement = FactoryBot.create(:maintenance_announcement, maintenance_template: @template, user: @current_user, begin_date: @begin_date, end_date: @end_date, email: nil)
    @announcement_with_mail = FactoryBot.create(:maintenance_announcement, maintenance_template: @template, user: @current_user, begin_date: @begin_date, end_date: @end_date, email: "mail@example.com")
  end

  after(:all) do
    # otherwise interferes with maintenance announcement controller specs
    MaintenanceTicket.destroy_all
  end

  describe "format_body" do
    it "formats the contents of a ticket, including machines" do
      x = FactoryBot.create(:maintenance_ticket, maintenance_announcement: @announcement, machines: [@m0, @m1])
      p = { 
        begin_date: @announcement.begin_date.to_formatted_s(:announcement_date),
        end_date: @announcement.end_date.to_formatted_s(:announcement_date),
        begin_time: @announcement.begin_date.to_formatted_s(:announcement_time),
        end_time: @announcement.end_date.to_formatted_s(:announcement_time),
        begin_full: @announcement.begin_date.to_formatted_s(:announcement_full),
        end_full: @announcement.end_date.to_formatted_s(:announcement_full),
        machines: @announcement.email ? "" : x.machines.pluck(:fqdn).join("\n"),
        user: @announcement.user.display_name 
      }

      expect(x.format_body).to eq(%q#%{begin_date} %{end_date} %{begin_time} %{end_time} %{begin_full} %{end_full} %{machines} %{user}# % p)
    end
  end

  describe "format_subject" do
    it "formats the subject of a ticket, with machines" do
      x = FactoryBot.create(:maintenance_ticket, maintenance_announcement: @announcement, machines: [@m0, @m1])
      p = { 
        begin_date: @announcement.begin_date.to_formatted_s(:announcement_date),
        end_date: @announcement.end_date.to_formatted_s(:announcement_date),
        begin_time: @announcement.begin_date.to_formatted_s(:announcement_time),
        end_time: @announcement.end_date.to_formatted_s(:announcement_time),
        begin_full: @announcement.begin_date.to_formatted_s(:announcement_full),
        end_full: @announcement.end_date.to_formatted_s(:announcement_full),
        machines: @announcement.email ? "" : x.machines.pluck(:fqdn).join("\n"),
        user: @announcement.user.display_name 
      }
      expect(x.format_subject).to eq(%q#%{begin_date} %{end_date} %{begin_time} %{end_time} %{begin_full} %{end_full} %{machines} %{user}# % p)
    end
  end

  describe "email" do
    describe "without announcement email" do
      it "returns the email address for the owner" do
        x = FactoryBot.create(:maintenance_ticket, maintenance_announcement: @announcement, machines: [@m0, @m1])

        expect(x.email).to eq(@owner0.announcement_contact)
      end
    end

    describe "with announcement email" do
      it "returns the email address of the announcement" do
        x = FactoryBot.create(:maintenance_ticket, maintenance_announcement: @announcement_with_mail, machines: [@m0, @m1])
        expect(x.email).to eq(@announcement_with_mail.email)
      end
    end
  end

  describe "rt_queue" do
    describe "without owner's RT queue" do
      it "returns the queue name from configuration file" do
        x = FactoryBot.create(:maintenance_ticket)
        expect(x.rt_queue).to eq(IDB.config.rt.queue)
      end

     it "returns the queue name from configuration file when owners queue is blank" do
        owner1 = FactoryBot.create(:owner, users: [@current_user], announcement_contact: "owner1@example.org", rt_queue: "")
        m2 = FactoryBot.create(:machine, owner: owner1, announcement_deadline: 0)
        x = FactoryBot.create(:maintenance_ticket, maintenance_announcement: @announcement, machines: [m2])
        expect(x.rt_queue).to eq(IDB.config.rt.queue)
      end
    end

    describe "with owner's RT queue" do
      it "returns the queue name from configuration file" do
        owner1 = FactoryBot.create(:owner, users: [@current_user], announcement_contact: "owner1@example.org", rt_queue: IDB.config.rt.queue)
        m2 = FactoryBot.create(:machine, owner: owner1, announcement_deadline: 0)
        x = FactoryBot.create(:maintenance_ticket, maintenance_announcement: @announcement, machines: [m2])
        expect(x.rt_queue).to eq(owner1.rt_queue)
      end
    end
  end
end
