class AnalyzeMediaJob < Struct.new(:id)
  def perform
    media_item = MediaItem.find id
    analyzer = MediaItemAnalyzer.new media_item

    analyzer.process!
  end
end