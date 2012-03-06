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
      user.media_items.where(is_processed: false).each do |item|
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

        message.user_location = user.locations.find_by_commission_id commission.id
        message.save!

        puts "Location: #{message.user_location.inspect}"
      end

      puts "\n"
    end
  end

  task protocols: :environment do
    UserMessage.where(key: ["protocol_photo", "protocol_photo_copy"]).each do |message|
      message.media_items.each do |item|
        MediaItemAnalyzer.new(item).process!(force: true)
      end
    end
  end

  task delete_duplications: :environment do
    Commission.includes(:protocol_photos).each do |commission|
      puts "Commission: #{commission.number}(#{commission.id})"
      names = []
      to_destroy = []
      commission.protocol_photos.each do |photo|
        next unless photo.image.url.present?
        name = photo.image.url.split("/").last
        if names.include? name
          puts "\t#{name} = destroy"
          to_destroy << photo
        else
          puts "\t#{name}"
          names << name
        end
      end

      to_destroy.each do |photo|
        photo.destroy
      end
    end
  end

  task ckeck_messages_location: :environment do
    check_list_names = CheckListItem.all.map(&:name)
    not_check_list = []
    messages_with_media = []
    UserMessage.where("user_location_id is NULL").includes(:watcher_report).each do |message|
      puts "Message: #{message.id}"

      if message.polling_place_internal_id.present?
        location = message.user.locations.find_by_external_id message.polling_place_internal_id
        unless location
          puts "LOCATION NOT FOUND"
          next
        end
      elsif
        puts "!! OLD API !!!"
        next
      end

      if check_list_names.include? message.key
        if message.watcher_report.present?
          if location
            message.update_column :user_location_id, location.id
            messages_with_media << message.id if message.media_items.exists?
          else
            puts "LOCATION NOT FOUND"
            next
          end
        else
          puts "!! WATCHER REPORT WASN't CREATED !!'"
        end
      else
        puts "!! NOT CHECKLIST !!"
        not_check_list << message.key unless not_check_list.include? message.key
      end

    end
    
    puts not_check_list.inspect
    puts messages_with_media.inspect
  end
  
  task broken_timestamp: :environment do
    WatcherReport.where("timestamp > '2012-03-07 01:00:00'").update_all("status = 'broken_timestamp'")
  end
  
  task before_vote: :environment do
    WatcherReport.where("timestamp < '2012-03-04 00:00:01'").update_all("status = 'training'")
  end
  
  task undefined: :environment do
    UserMessage.where("value = '0' OR value ='undef'").each do |message|
      UserMessagesAnalyzer.new(message).process!
    end
  end
  
  task duplicate_locations: :environment do
    
    User.includes(:locations).all.each do |user|
      next if user.locations.size < 2
      
      h_location = user.locations.inject({}) do |result, element|
        (result[element.commission.number] ||= []) << element
        result
      end
      
      h_location.values.each do |locations|
        if locations.map(&:status).include? "approved"
          locations.each do |location|
            unless location.status.approved?
              location.status = "approved"
              location.save!
            end
          end
        end
      end
      
    end
    
  end
  
end