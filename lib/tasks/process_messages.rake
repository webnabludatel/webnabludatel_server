# encoding: utf-8

namespace :process do

  task user_messages: :environment do
    User.all.each do |user|
      user.user_messages.where(is_processed: false, is_delayed: false).each do |message|
        analyzer = UserMessagesAnalyzer.new message
        begin
          analyzer.process!
        rescue => e
          puts "Message: #{message.inspect}"
          puts "e: #{e}"
        end
      end
    end
  end

  task media_items: :environment do
    User.all.each do |user|
      user.media_items.where(is_processed: false, is_delayed: false).each do |item|
        analyzer = MediaItemAnalyzer.new item
        begin
          analyzer.process!
        rescue => e
          puts "MediaItem: #{item.inspect}"
          puts "e: #{e}"
        end
      end
    end
  end

  task observer_status: :environment do
    UserMessage.where(is_delayed: false).where(key: Analyzer::OBSERVER_STATUS_KEYS).order(:timestamp).each do |message|
      analyzer = UserMessagesAnalyzer.new message
        begin
          analyzer.process!
        rescue => e
          puts "Message: #{message.inspect}"
          puts "e: #{e}"
        end
    end
  end

  task voters_lists_are_ok: :environment do
    UserMessage.where(is_delayed: false).where(key: :voters_lists_are_ok).order(:timestamp).each do |message|
      analyzer = UserMessagesAnalyzer.new message
        begin
          analyzer.process!
        rescue => e
          puts "Message: #{message.inspect}"
          puts "e: #{e}"
        end
    end
  end

  task process_official_observer: :environment do
    UserMessage.where(is_delayed: false, is_processed: false).where(key: :official_observer).order(:timestamp).each do |message|
      analyzer = UserMessagesAnalyzer.new message
        begin
          analyzer.process!
        rescue => e
          puts "Message: #{message.inspect}"
          puts "e: #{e}"
        end
      message.media_items.each do |item|
        media_analyzer = MediaItemAnalyzer.new item
          begin
            media_analyzer.process!
          rescue => e
            puts "MediaItem: #{item.inspect}"
            puts "e: #{e}"
          end
      end
    end
  end

  task failed: :environment do
    check_list_keys = CheckListItem.all.map(&:name)

    UserMessage.where(is_delayed: false, is_processed: false).where("value is NOT NULL").where(key: check_list_keys).order(:timestamp).each do |message|
      next if message.user.watcher_reports.where(key: message.key).where("timestamp > ?", message.timestamp).exists?

      UserMessagesAnalyzer.new(message).process!
      message.media_items.each do |item|
        next if item.deleted?
        MediaItemAnalyzer.new(item).process!
      end
    end
  end

  task locations: :environment do
    UserLocation.where("external_id is NULL").each do |location|
      puts "Fixing location: #{location.id}: #{location.user_messages.map(&:id).inspect}"
      messages = location.user_messages

      polling_place_internal_id = nil
      messages.each do |message|
        if polling_place_internal_id && message.polling_place_internal_id && polling_place_internal_id != message.polling_place_internal_id
          puts "Fuck: #{polling_place_internal_id} : #{message.polling_place_internal_id}"
          polling_place_internal_id = nil
          break
        end

        polling_place_internal_id = message.polling_place_internal_id
      end

      puts "External: #{polling_place_internal_id}"
      location.external_id = polling_place_internal_id
      location.save!
      puts "\n"
    end
  end

  task user_messages_without_location: :environment do
    UserMessage.where("user_location_id is NULL").each do |message|
      puts "Message: #{message.id}"

      if message.polling_place_internal_id.present?
        message.user_location = message.user.locations.where(external_id: message.polling_place_internal_id).first
        message.save!

        puts "Location: #{message.user_location.inspect}"
      else
        user = message.user
        region = Region.find_by_external_id message.polling_place_region

        unless region
          puts "No region: #{message.polling_place_region}"
          next
        end

        commission = user.commissions.where(number: message.polling_place_id, region_id: region.id).first

        unless commission
          puts "No commission for: #{message.polling_place_id} - #{region.id}"
          next
        end

        message.user_location = user.locations.find_by_comission_id commission.id
        message.save!

        puts "Location: #{message.user_location.inspect}"
      end

      puts "\n"
    end
  end

end