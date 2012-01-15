class Admin::WatcherReferalsController < Admin::Base
  before_filter :find_referal, :only => [:approve, :reject, :problem]

  def moderate
    @referal = WatcherReferal.not_done.first
  end

  def approve
    @referal.approve! params[:watcher_referal][:comment]

    redirect_to moderate_admin_watcher_referals_path
  end

  def reject
    @referal.reject! params[:watcher_referal][:comment]

    redirect_to moderate_admin_watcher_referals_path
  end
  
  def problem
    @referal.problem! params[:watcher_referal][:comment]

    redirect_to  moderate_admin_watcher_referals_path
  end

  protected
    def find_referal
      @reffral = WatcherReferal.find params[:id]
    end
end