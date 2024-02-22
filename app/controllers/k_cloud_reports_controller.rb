class KCloudReportsController < ApplicationController
  def index
    @kcrs = KCloudReport.all.order('created_at DESC').paginate(:page => params[:page], :per_page => 50)
  end

  def show
    @kcloudreport = KCloudReport.find(params[:id])
  end
end
