class AlertMailer < ActionMailer::Base
  default from: IDB.config.mail.from

  def dangling_maintenance_record(record, user)
    @record = record
    @user = user

    mail({
      to: IDB.config.mail.to,
      subject: %([IDB] ALERT - Dangling maintenance record for #{record.fqdn})
    })
  end
end
