class Admin::WatcherReferralsController < Admin::BaseController
  load_and_authorize_resource
  before_filter :find_referral, :only => [:approve, :reject, :problem]

  def moderate
    # Not the best way because two moderators can moderate one user at the same time.
    @user = User.pending.first
  end

  def index
    @watcher_referrals = WatcherReferral.order("created_at DESC").pending.page params[:page]
  end

  def approve
    @referral.approve! #params[:watcher_referral][:comment]

    render :js => "$('#watcher_referral_#{@referral.id}_status').html('approve');$('#watcher_referral_#{@referral.id}_actions').remove()"
    #redirect_to admin_watcher_referrals_path
  end

  def reject
    @referral.reject! #params[:watcher_referral][:comment]

    render :js => "$('#watcher_referral_#{@referral.id}_status').html('reject');$('#watcher_referral_#{@referral.id}_actions').remove()"

    #redirect_to admin_watcher_referrals_path
  end
  
  def problem
    @referral.problem! #params[:watcher_referral][:comment]

    render :js => "$('#watcher_referral_#{@referral.id}_status').html('problem');$('#watcher_referral_#{@referral.id}_actions').remove()"

    #redirect_to  admin_watcher_referrals_path
  end

  protected
    def find_referral
      @referral = WatcherReferral.find params[:id]
    end
end