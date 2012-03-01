class WatcherReportsController < ApplicationController

  def index
    @watcher_reports = WatcherReport.order("timestamp DESC").page params[:page]
  end

end