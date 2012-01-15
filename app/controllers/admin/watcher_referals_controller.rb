class Admin::WatcherReferalsController < Admin::Base
  before_filter :find_referal, :only => [:approve, :reject, :problem]

  def moderate
    @refferal = WatcherReferal.not_done.first
  end

  def approve
    @refferal.approve! params[:watcher_referal][:comment]

    redirect_to moderate_admin_watcher_referals_path
  end

  def reject
    @refferal.reject! params[:watcher_referal][:comment]

    redirect_to moderate_admin_watcher_referals_path
  end
  
  def problem
    @refferal.problem! params[:watcher_referal][:comment]

    redirect_to  moderate_admin_watcher_referals_path
  end

  protected
    def find_referal
      @refferal = WatcherReferal.find params[:id]
    end
end