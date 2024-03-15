class KCloudReportPresenter < Keynote::Presenter
  presents :kcloudreport

  delegate :ip, :created_at, :raw_data, :machine_name,
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
    all = ""
    return "" unless raw_data

    json_object = JSON.parse(raw_data.gsub('\"', '"').gsub('=>', ': ').gsub('nil', '""'))

    if json_object && json_object['users']
      if json_object['users']['count']
        all = json_object['users']['count']
      end

      if json_object['users']['countByPrivileges'] && json_object['users']['countByPrivileges']['ONLY_WEB']
        web_only = json_object['users']['countByPrivileges']['ONLY_WEB']
        full = (all.to_i - web_only.to_i).to_s
        return "#{all} / #{full} + #{web_only} WebApp"
      else
        return "#{all}"
      end
    else
      return "#{all}"
    end
  end

  def license_name
    return kcloudreport.license_name if kcloudreport.license_name
    return "" unless raw_data

    json_object = JSON.parse(raw_data.gsub('\"', '"').gsub('=>', ': ').gsub('nil', '""'))

    if json_object['license'] && json_object['license']['products'] && json_object['license']['products']['e4asub'] && json_object['license']['products']['e4asub']['sin']
      return json_object['license']['products']['e4asub']['sin'].join(",")
    end
  end

  def software_version
    return "" unless raw_data

    json_object = JSON.parse(raw_data.gsub('\"', '"').gsub('=>', ': ').gsub('nil', '""'))

    if json_object['software'] && json_object['software']['version']
      return json_object['software']['version']
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
