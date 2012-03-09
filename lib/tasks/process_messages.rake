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

  task set_location_external_id: :environment do
    UserLocation.where("external_id is NULL").each do |location|
      messages = location.user_messages.where(key: Analyzer::COMMISSION_KEYS)
      place_internal_ids = messages.map(&:polling_place_internal_id)
      puts "Fixing location: #{location.id}: #{place_internal_ids.inspect}"
    
      # It is not so optimal, but we it looks simpler and will work faster (i think) because we use internal array methods
      # And max size of array is 6.
      uniq_place_internal_ids = place_internal_ids.compact.uniq
      polling_place_internal_id = uniq_place_internal_ids.first
      puts "\rFixing location: #{location.id}: #{place_internal_ids.inspect}: #{uniq_place_internal_ids.inspect}: #{polling_place_internal_id.inspect}"
      next if polling_place_internal_id.nil? || uniq_place_internal_ids.length > 1
    
      location.external_id = polling_place_internal_id
      location.save!
      puts "\n"
    end
  end
  
  task delayed_messages: :environment do
    UserMessage.where(is_delayed: true).where("key not IN (?)", (Analyzer::COMMISSION_KEYS - ["district_banner_photo"])).each do |message|
      user = message.user
      message_analyzer = UserMessagesAnalyzer.new message
      
      parsed_location = message_analyzer.send(:parsed_location)
      puts "Message #{message.id}: #{message.key}: #{parsed_location ? parsed_location.inspect : "#{parsed_location.inspect} : #{message.value.inspect}"}"
      next unless parsed_location
      
      if message.timestamp > Time.now
        puts "\t: Inf timestamp: #{message.timestamp}"
        if user.user_messages.where(key: message.key).where("id != ?", message.id).where("timestamp < ?", Time.now).exists?
          puts "\t: Have normal messages"
          next
        end
      end
      
      puts "\tanalyzing message..."
      message_analyzer.process!
      
      message.media_items.each do |media_item|
        puts "\tanalyzing media item: #{media_item.id}"
        MediaItemAnalyzer.new(media_item).process!
      end
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

  task locations_with_duplicate_messages: :environment do
    User.joins(:user_messages).includes(:user_messages).where("user_messages.key" => Analyzer::COMMISSION_KEYS).where("user_messages.user_location_id is NULL").uniq.each do |user|
      messages = user.user_messages.where(key: Analyzer::COMMISSION_KEYS).order(:timestamp)

      new_location_messages = []
      prev_message = nil
      messages.each do |message|
        new_location_messages << message if prev_message.nil? ||
                                            !prev_message.key == message.key ||
                                            message.user_location_id.present? ||
                                            prev_message.user_location_id.present? ||
                                            prev_message.polling_place_internal_id == message.polling_place_internal_id
        prev_message = message
      end

      puts "User (#{user.id}):"
      puts "\tmessages(key:value:polling_place_internal_id:user_location-id): #{messages.map{|m| "#{m.key} : #{m.value} : #{m.polling_place_internal_id} : #{m.user_location_id}" }.inspect}"
      puts "\tnew_location_messages(key:value:polling_place_internal_id:user_location-id): #{new_location_messages.map{|m| "#{m.key} : #{m.value} : #{m.polling_place_internal_id} : #{m.user_location_id}" }.inspect}"
      new_location_messages.reject!{|message| message.user_location_id.present? }

      #new_location_messages.each do |message|
      #  UserMessagesAnalyzer.new(message).process!(force: true, force_old_api: true)
      #end

      puts "\n"
    end
  end

  task protocol_copy_photo: :environment do
    UserMessage.includes(:media_items).where(key: "protocol_copy_photo").where("user_location_id IS NOT NULL").order(:timestamp).each do |message|
      UserMessagesAnalyzer.new(message).process!(force: true) if !message.is_processed? || message.is_delayed?

      message.media_items.where(is_processed: false).each do |item|
        puts "re-processing media_item: #{item.id}"
        MediaItemAnalyzer.new(item).process!
      end
    end
  end

  task fix_timestamps: :environment do
    UserMessage.where("timestamp > ?", Time.now + 100.years).order(:timestamp).each do |message|
      puts "Processing message: #{message.id} #{message.key}:#{message.value}"

      message.update_column :timestamp, Time.at(message.timestamp.to_i / 1000)
      analyzer = UserMessagesAnalyzer.new message

      case message.key
        when *Analyzer::COMMISSION_KEYS
          analyzer.process!(force: true) if !message.is_processed? && message.is_delayed? || message.user_location.blank?
          process_media_items(message) if message.key == "district_banner_photo"
        when *Analyzer::SOS_KEYS
          analyzer.process! force: true
          process_media_item message
        when *Analyzer::PROFILE_KEYS
          analyzer.process! unless message.is_processed?
        when *Analyzer::RESULT_PHOTO_KEYS
          analyzer.process! if !message.is_processed? || message.is_delayed?
          process_media_items message
        when *Analyzer::OFFICIAL_OBSERVER_KEYS
          analyzer.process! force: true
          process_media_items message
        else
          check_list_item = CheckListItem.find_by_name message.key
          if check_list_item
            analyzer.process! message
            process_media_items message
          elsif !Analyzer::OBSERVER_STATUS_KEYS.include? message.key
            Airbrake.notify(
                error_class:    "API Error",
                error_message:  "Unknown message key: #{message.key}",
                parameters:     { payload: message.inspect }
            )
          end
      end
    end
  end

  def process_media_items(message)
    message.media_items.each do |item|
      if item.timestamp > Time.now + 100.years || !item.is_processed?
        item.update_column(:timestamp, Time.at(item.timestamp.to_i / 1000))
        MediaItemAnalyzer.new(item).process!(force: true)
      end
    end
  end

end