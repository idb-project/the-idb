class KCloudReportsController < ApplicationController
  def index
    @kcrs = KCloudReport.all
  end
end
