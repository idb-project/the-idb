class KCloudReportPresenter < Keynote::Presenter
  presents :kcloudreport

  delegate :ip, :created_at, :raw_data,
           to: :kcloudreport

  def id
    kcloudreport.id
  end

  def created_at
    kcloudreport.created_at.localtime.strftime('%F %T')
  end

  def machine_link
    kcloudreport.machine ? link_to(kcloudreport.machine.fqdn, kcloudreport.machine) : ""
  end

  def kcloudreport_link
    link_to(created_at, kcloudreport)
  end

  def data
    json_object = eval(raw_data.gsub('=>', ':'))
    json_object = JSON.pretty_generate(json_object)
    json_object = json_object.gsub("\n", "<br/>")
    json_object = json_object.gsub("\"", "")
    json_object = json_object.gsub(" ", "&nbsp;&nbsp;")
    json_object.html_safe
  end
end
