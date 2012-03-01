# encoding: utf-8

namespace :process do

  task user_messages: :environment do
    User.all.each do |user|
      user.user_messages.where(is_processed: false).each do |message|
        puts "Message: #{message.inspect}"
        analyzer = UserMessagesAnalyzer.new message
        analyzer.process!
      end
    end
  end

  task media_items: :environment do
    User.all.each do |user|
      user.media_items.where(is_processed: false).each do |item|
        puts "MediaItem: #{item.inspect}"
        analyzer = MediaItemAnalyzer.new item
        analyzer.process!
      end
    end
  end

end