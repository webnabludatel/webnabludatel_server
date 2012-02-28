class AnalyzeUserMessageJob < Struct.new(:id)
  def perform
    user_message = UserMessage.find id
    analyzer = UserMessagesAnalyzer.new user_message

    analyzer.process!
  end

  def error(job, exception)
    Airbrake.notify(exception)
  end
end