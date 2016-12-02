class WarrantyReminderWorker
  include Sidekiq::Worker

  def perform
    early_date = (DateTime.now+2.weeks).strftime("%Y-%m-%d")
    late_date = (DateTime.now+3.months).strftime("%Y-%m-%d")

    early_date_items = Inventory.joins(:inventory_status).where(warranty_end: early_date, inventory_statuses: {inactive: false})
    late_date_items = Inventory.joins(:inventory_status).where(warranty_end: late_date, inventory_statuses: {inactive: false})

    if (!early_date_items.empty? || !late_date_items.empty?)
      WarrantyReminderMailer.warranty_email(early_date_items, late_date_items).deliver
    end
  end
end
