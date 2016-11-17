class ObjectChangeMailer < ActionMailer::Base
  default from: IDB.config.mail.from

  def diff_email(version, username)
    @version = Keynote.present(self, :version, version)

    if version.item.class.to_s == "Machine"
      if version.item.auto_update
        tpl_name = 'machine_auto_diff_email'
      else
        tpl_name = 'machine_diff_email'
      end
    elsif version.item.class.to_s == "Inventory"
      tpl_name = 'inventory_diff_email'
    else
      tpl_name = 'diff_email'
    end

    mail({
      to: IDB.config.mail.to,
      subject: @version.mail_subject.gsub(/\?$/, username),
      template_name: tpl_name
    })
  end
end
