class KCloudReportsController < ApplicationController
  def index
    @kcrs = KCloudReport.all.order('created_at DESC')
  end
end
