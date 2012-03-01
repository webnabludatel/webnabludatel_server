class AnalyzeMediaJob < Struct.new(:id)
  def perform
    @media_item = MediaItem.find id
    analyzer = MediaItemAnalyzer.new @media_item

    analyzer.process!
  end

  def error(job, exception)
    Rails.logger.error "Media Item Analyzer Error: #{@media_item.inspect}"
    Airbrake.notify(exception)
  end
end