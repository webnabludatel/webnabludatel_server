# encoding: utf-8

namespace :reprocess do

  task user_messages: :environment do
    User.all.each do |user|
      user.user_messages.where(is_processed: false).each do |message|
        analyzer = UserMessagesAnalyzer.new message
        analyzer.process!
      end
    end
  end

  task media_items: :environment do
    User.all.each do |user|
      user.media_items.where(is_processed: false).each do |item|
        analyzer = MediaItemAnalyzer.new item
        analyzer.process!
      end
    end
  end

end