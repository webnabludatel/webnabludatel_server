class Admin::UserLocationsController < Admin::BaseController
  load_and_authorize_resource
  before_filter :find_user_locations, :only => [:approve, :reject, :problem]

  def index
    @user_locations = UserLocation.pending.joins(:photos).uniq.order("created_at").page(params[:page])
  end

  def approve
    @user_location.approve! #params[:watcher_referral][:comment]

    render :js => "$('##{dom_id(@user_location, :status)}').html('APPPROVED');$('##{dom_id(@user_location, :controls)}').remove()"
  end

  def reject
    @user_location.reject! #params[:watcher_referral][:comment]

    render :js => "$('##{dom_id(@user_location, :status)}').html('REJECTED');$('##{dom_id(@user_location, :controls)}').remove()"
  end

  def problem
    @user_location.problem! #params[:watcher_referral][:comment]

    render :js => "$('##{dom_id(@user_location, :status)}').html('PROBLEM');$('##{dom_id(@user_location, :controls)}').remove()"
  end


  protected
  def find_user_locations
    @user_location = UserLocation.find params[:id]
  end
end