class UsersController < ApplicationController

  skip_before_filter :beta_authenticate

  before_filter :find_user

  def show
  end

  def show_future
    @watcher_reports = @user.watcher_reports.order("timestamp DESC").includes(:location).includes(:commission)
  end

  protected
    def find_user
      @user = User.find params[:id]
    end

end