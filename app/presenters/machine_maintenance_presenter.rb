class MachineMaintenancePresenter < Keynote::Presenter
  presents :record

  def machine_name
    record.machine ? record.machine.name : record.fqdn
  end

  def title
    "#{machine_name} / #{date} / #{username}"
  end

  def date
    record.created_at.localtime.strftime('%F %T')
  end

  def machine_link
    record.machine ? link_to(machine_name, record.machine) : machine_name
  end

  def username
    record.user.name
  end

  def logfile
    build_html do
      pre do
        # Try to display a sane logfile.
        record.logfile.to_s.split("\r\n").map {|s|
          s.split("\r").last
        }.join("\n")
      end
    end
  end

  def logfile_link
    link_to 'show', maintenance_record_path(record)
  end

  def dangling?
    record.machine.nil?
  end

  def machine_list
    Machine.order(fqdn: :asc).map {|m| [m.name, m.id] }
  end

  def css_class
    dangling? ? 'text-error' : ''
  end

  def attachment_list
    return "none" if (record.attachments && record.attachments.size == 0)

    list = "<ul>"
    record.attachments.each do |att|
      list += "<li><a href='#{att.attachment.url}' target='_blank'>#{att.attachment_file_name}</a></li>"
    end
    list += "</ul>"
  end
end
