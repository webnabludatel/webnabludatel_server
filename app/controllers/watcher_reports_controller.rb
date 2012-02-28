class WatcherReportsController < ApplicationController

  def index
    @watcher_reports = WatcherReport.order(:timestamp).page params[:page]
  end

end