class Admin::UserLocationsController < Admin::BaseController
  load_and_authorize_resource
  before_filter :find_user_locations, :only => [:approve, :reject, :problem]

  def index
    @user_locations = UserLocation.order("created_at DESC").page params[:page]
  end

  def approve
    @user_location.approve! params[:user_location][:comment]

    redirect_to admin_user_locations_path
  end

  def reject
    @user_location.reject! params[:user_location][:comment]

    redirect_to admin_user_locations_path
  end

  def problem
    @user_location.problem! params[:user_location][:comment]

    redirect_to  admin_user_locations_path
  end

  protected
  def find_user_locations
    @user_location = UserLocation.find params[:id]
  end
end