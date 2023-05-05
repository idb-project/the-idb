class KCloudReportPresenter < Keynote::Presenter
  presents :kcloudreport

  delegate :ip,
           to: :kcloudreport

  def id
    kcloudreport.id
  end
end
