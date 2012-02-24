# encoding: utf-8

module WatcherReport::StatusCalculator

  def self.calculate(current_status, location_status, watcher_status)
    return current_status if %W(manual_approved manual_rejected manual_suspicious).include? current_status
    return nil unless watcher_status
    return watcher_status if watcher_status == "pending"

    if watcher_status == "approved"
      return "no_location" unless location_status
      return location_status == "approved" ? "approved" : "location_not_approved"
    end

    watcher_status
  end

end