class KCloudReportPresenter < Keynote::Presenter
  presents :kcloudreport

  delegate :ip, :created_at, :raw_data, :machine_name, :license_name,
           to: :kcloudreport

  def id
    kcloudreport.id
  end

  def created_at
    kcloudreport.created_at.localtime.strftime('%F %T')
  end

  def machine_link
    if kcloudreport.machine
      link_to(kcloudreport.machine.fqdn, kcloudreport.machine)
    else
      kcloudreport.machine_name
    end
  end

  def owner
    kcloudreport.machine ? kcloudreport.machine.owner.name : ""
  end

  def kcloudreport_link
    link_to(created_at, kcloudreport)
  end

  def usercount
    return "" unless raw_data
    json_object = JSON.parse(raw_data.gsub('\"', '"').gsub('=>', ': ').gsub('nil', '""'))
    all = json_object['users']['count']

    if json_object['users']['countByPrivileges'] && json_object['users']['countByPrivileges']['ONLY_WEB']
      web_only = json_object['users']['countByPrivileges']['ONLY_WEB']
      full = (all.to_i - web_only.to_i).to_s
      return "#{all} / #{full} + #{web_only} WebApp"
    else
      return "#{all}"
    end
  end

  def data
    return "" unless raw_data
    json_object = eval(raw_data.gsub('=>', ':'))
    json_object = JSON.pretty_generate(json_object)
    json_object = json_object.gsub("\n", "<br/>")
    json_object = json_object.gsub("\"", "")
    json_object = json_object.gsub(" ", "&nbsp;&nbsp;")
    json_object = json_object.gsub('nil', '""')
    json_object.html_safe
  end
end
