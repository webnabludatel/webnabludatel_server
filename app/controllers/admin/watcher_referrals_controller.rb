class Admin::WatcherReferralsController < Admin::BaseController
  before_filter :find_referral, :only => [:approve, :reject, :problem]

  def moderate
    @referral = WatcherReferral.not_done.first
  end

  def approve
    @referral.approve! params[:watcher_referral][:comment]

    redirect_to moderate_admin_watcher_referrals_path
  end

  def reject
    @referral.reject! params[:watcher_referral][:comment]

    redirect_to moderate_admin_watcher_referrals_path
  end
  
  def problem
    @referral.problem! params[:watcher_referral][:comment]

    redirect_to  moderate_admin_watcher_referrals_path
  end

  protected
    def find_referral
      @referral = WatcherReferral.find params[:id]
    end
end