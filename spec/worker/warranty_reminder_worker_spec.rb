require 'spec_helper'

describe WarrantyReminderWorker do
  describe "perform" do
    before(:each) do
      allow(User).to receive(:current).and_return(nil)
      @w = WarrantyReminderWorker.new
    end

    it "does not send out an email without any inventory items existing" do
      expect(@w.perform).to be_nil
    end

    it "does not send out an email without inventory items that have a warranty end date" do
      create(:inventory)
      expect(@w.perform).to be_nil
    end

    it "does not send out an email without inventory items that have a non-matching warranty end date" do
      create(:inventory, warranty_end: (DateTime.now+2.years).strftime("%Y-%m-%d"))
      expect(@w.perform).to be_nil
    end

    it "does not send out an email with inventory items that have a matching warranty end date but status inactive" do
      create(:inventory, warranty_end: (DateTime.now+2.weeks).strftime("%Y-%m-%d"), inventory_status: create(:inventory_status, inactive: true))
      expect(@w.perform).to be_nil
    end

    it "does send out an email with inventory items that have a matching warranty end date" do
      create(:inventory, warranty_end: (DateTime.now+2.weeks).strftime("%Y-%m-%d"), inventory_status: create(:inventory_status, inactive: false))
      expect(@w.perform).to be_instance_of(Mail::Message)
    end
  end
end
