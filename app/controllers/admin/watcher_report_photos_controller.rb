# encoding: utf-8

class Admin::WatcherReportPhotosController < Admin::BaseController
  load_and_authorize_resource

  def index
    @watcher_report_photos = WatcherReportPhoto.includes(:watcher_report => :user).order("id").page(params[:page])
  end

  def update
    @watcher_report_photo = WatcherReportPhoto.find(params[:id])

    if @watcher_report_photo.update_attributes(:status => params[:status])
      render :js => "$('##{dom_id(@watcher_report_photo, :status)}').html('#{@watcher_report_photo.status}');$('##{dom_id(@watcher_report_photo, :controls)}').html('<p>Сохранено</p>');"
    else
      render :js => "$('##{dom_id(@watcher_report_photo, :controls)}').append('<p>ERROR: #{@watcher_report_photo.errors.full_messages.inspect}</p>');"
    end
  end
end