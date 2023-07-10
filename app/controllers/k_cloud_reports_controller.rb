class KCloudReportsController < ApplicationController
  def index
    @kcrs = KCloudReport.all.order('created_at DESC')
  end

  def show
    @kcloudreport = KCloudReport.find(params[:id])
  end
end
