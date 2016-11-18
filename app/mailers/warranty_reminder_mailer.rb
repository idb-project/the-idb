class WarrantyReminderMailer < ActionMailer::Base
  default from: IDB.config.mail.from

  def warranty_email(early_date_items, late_date_items)
    tpl_name = 'warranty_email'
    @early_date_items = early_date_items
    @late_date_items = late_date_items

    mail({
      to: IDB.config.mail.to,
      subject: "[#{IDB.config.design.title}] Warranty reminder: #{early_date_items.size+late_date_items.size} items",
      template_name: tpl_name
    })
  end
end
