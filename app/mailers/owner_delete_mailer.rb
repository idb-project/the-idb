class OwnerDeleteMailer < ActionMailer::Base
  default from: IDB.config.mail.from

  def delete_email(ownername, username)
    tpl_name = 'delete_email'
    @softdelete = IDB.config.modules.softdelete

    mail({
      to: IDB.config.mail.to,
      subject: "[#{IDB.config.design.title}] Owner \"#{ownername}\" deleted by #{username}",
      template_name: tpl_name
    })
  end
end
