class UserDeleteMailer < ActionMailer::Base
  default from: IDB.config.mail.from

  def delete_email(username, operatorname)
    tpl_name = 'delete_email'
    @softdelete = IDB.config.modules.softdelete

    mail({
      to: IDB.config.mail.to,
      subject: "[#{IDB.config.design.title}] User \"#{username}\" deleted by #{operatorname}",
      template_name: tpl_name
    })
  end
end
