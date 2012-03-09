class ReportsController < ApplicationController
  def index
    @active_users_count = User.active_count
    @violations_count = WatcherReport.violations.size
    @regulations_count = WatcherReport.regulations.size

    @violation_photos = WatcherReportPhoto.interesting.limit(10)

    violation_columns = %W(id violation_text).map {|c| "check_list_items.#{c}"}.join(", ")
    @popular_violations = CheckListItem.
        joins(:watcher_reports).
        select("#{violation_columns}, count(watcher_reports.id) as wcnt").
        where("watcher_reports.is_violation = true").
        group(violation_columns).
        order("wcnt desc").
        limit(10)

    commission_columns = %W(id number kind region_id).map {|c| "commissions.#{c}"}.join(", ")
    @bad_commissions = Commission.
        joins(:watcher_reports).
        select("#{commission_columns}, count(watcher_reports.id) as wcnt").
        where("watcher_reports.is_violation = true").
        group(commission_columns).
        order("wcnt desc").
        limit(10)
  end

  def protocols
    location_ids = UserLocation.joins(:protocol_photos).order(:id).uniq.pluck("user_locations.id")
    @locations = UserLocation.where(id: location_ids).order(:id).page(params[:page]).per(20)
  end
end
