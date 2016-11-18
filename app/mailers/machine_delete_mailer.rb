class MachineDeleteMailer < ActionMailer::Base
  default from: IDB.config.mail.from

  def delete_email(fqdn, username)
    tpl_name = 'delete_email'
    @softdelete = IDB.config.modules.softdelete
    @machine = Machine.unscope(where: :deleted_at).where(fqdn: fqdn).last

    mail({
      to: IDB.config.mail.to,
      subject: "[#{IDB.config.design.title}] Machine \"#{fqdn}\" deleted by #{username}",
      template_name: tpl_name
    })
  end
end
