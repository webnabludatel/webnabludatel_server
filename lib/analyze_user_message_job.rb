class AnalyzeUserMessageJob < Struct.new(:id)
  def perform
    @user_message = UserMessage.find id
    analyzer = UserMessagesAnalyzer.new @user_message

    analyzer.process!
  end

  def error(job, exception)
    Rails.logger.error "User Message Analyzer Error: #{@user_message.inspect}"
    Airbrake.notify(exception)
  end
end