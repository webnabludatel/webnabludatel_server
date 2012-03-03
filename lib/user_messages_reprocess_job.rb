class UserMessagesReprocessJob < Struct.new(:id)
  def perform
    @user_location = UserLocation.find id
    analyzer = UserMessagesAnalyzer.reprocess_delayed @user_location

    analyzer.process!
  end

  def error(job, exception)
    Rails.logger.error "User Message Analyzer Error: #{@user_message.inspect}"
    Airbrake.notify(exception)
  end
end