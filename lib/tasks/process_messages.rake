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
    #User.all.each do |user|
    #  user.user_messages.where(key: "district_number").each do |message|
    #    location_external_ids = user.locations.map(&:external_id)
    #    puts "\n"
    #    puts "\n"
    #    puts "\n"
    #    puts "------------------------------------------------------"
    #
    #    if message.polling_place_internal_id.present? && message.user_location.blank?
    #      unless location_external_ids.include? message.polling_place_internal_id
    #        puts "Processing: #{message.inspect}"
    #        UserMessagesAnalyzer.new(message).process!
    #      end
    #    elsif message.polling_place_id.present? && message.polling_place_region.present? && message.user_location.blank?
    #      region = Region.find_by_external_id message.polling_place_region
    #      unless user.commissions.where(region_id: region.id, number: message.polling_place_id).exists?
    #        puts "Processing: #{message.inspect}"
    #        UserMessagesAnalyzer.new(message).process!
    #      end
    #    end
    #  end
    #end

    UserLocation.where("external_id is NULL").each do |location|
      puts "Fixing location: #{location.id}: #{location.user_messages.map(&:id).inspect}"
      messages = location.user_messages

      polling_place_internal_id = nil
      messages.each do |message|
        if polling_place_internal_id && polling_place_internal_id != message.polling_place_internal_id
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

end