class UsersController < ApplicationController

  skip_before_filter :beta_authenticate

  before_filter :find_user

  def show
    @locations = @user.locations.select {|l| l.watcher_reports.where("status != 'training'").where("status != 'broken_timestamp'").size > 0}
  end

  def show_future
    @watcher_reports = @user.watcher_reports.order("timestamp DESC").includes(:user_location).includes(:commission).page params[:page]
  end

  protected
    def find_user
      @user = User.find params[:id]
    end

end