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
    UserMessage.includes(:user).where("user_location_id is NULL").where("key NOT IN (?)", Analyzer::COMMISSION_KEYS).where("key NOT IN (?)", Analyzer::PROFILE_KEYS).where("key NOT IN (?)", Analyzer::OBSERVER_STATUS_KEYS).where("key NOT IN (?)", Analyzer::OFFICIAL_OBSERVER_KEYS).order(:timestamp).each do |message|
      puts "Message: #{message.id}: #{message.key}: #{message.value}: is_processed #{message.is_processed?.inspect}: is_delayed: #{message.is_delayed?.inspect}"

      location = get_user_location_by_message(message)
      puts "\tLocation: #{location.inspect}"

      if location
        message.user_location = location
        message.save!

        UserMessagesAnalyzer.new(message).process!(force: true)
        process_media_items(message)
      else
        user.locations.each do |location|
          puts "\t#{location.distance_to([message.latitude, message.longitude])}"
        end
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
          process_media_items message
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
            analyzer.process! force: true
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

  task fix_orphan_reports: :environment do
    WatcherReport.includes(:user_messages).each do |orphan|
      next if orphan.user_messages.present?

      puts "Processing orphan report: #{orphan.id}"

      user = orphan.user

      user_messages = user.user_messages.where(key: orphan.key).includes(:watcher_report).order("timestamp DESC")

      puts "ERROR: NO USER MESSAGES WITH KEY: #{orphan.key}" and next if user_messages.blank?

      user_message = user_messages.first
      watcher_report = user_message.watcher_report
      puts "ERROR: NO REPORT FOR THE LAST MESSAGE: #{user_message.id}" and next unless watcher_report

      puts "ERROR: DON'T KNOW WHAT TO DO: orphan value: #{orphan.value}; report: #{watcher_report.value}" and next if orphan.value != watcher_report.value
      puts "ERROR: orphan photos doesn't match report photos" and next if orphan.photos != watcher_report.photos
      puts "ERROR: orphan videos doesn't match reports videos" and next if orphan.videos != watcher_report.videos

      puts "destroying orphan #{orphan.id}"
      orphan.destroy
    end
  end

  task fix_watcher_reports_with_broken_timestamp: :environment do
    WatcherReport.where(status: "broken_timestamp").includes(:user_messages).each do |report|
      puts "Processing report: #{report.id}"

      user_message = report.user_messages.last
      UserMessagesAnalyzer.new(user_message).process!(force: true)
      user_message.media_items.each do |item|
        MediaItemAnalyzer.new(item).process!(force: true)
      end
    end
  end

  task fix_dubl_location_messages: :environment do
    User.joins(:user_messages).includes(:user_messages).where("user_messages.key" => Analyzer::COMMISSION_KEYS).where("user_messages.user_location_id is NULL").uniq.each do |user|
      puts "USER: #{user.id}"
      processed = []
      current_hash = {}
      user.user_messages.where(key: Analyzer::COMMISSION_KEYS).where("user_location_id is NULL").order(:timestamp).each do |message|
        puts "\tProcessing message: #{message.id}: #{message.key}"
        if m = current_hash[message.key]
          if m[:message].key == message.key && m[:message].value == message.value
            puts "\t\tDubl"
            current_hash[message.key][:dubls] << message
          else
            puts "\t\tNew Location"
            processed << current_hash
            current_hash = {}
          end
        else
          puts "\t\tNew message"
          current_hash[message.key] = { message: message, dubls: [] }
        end
      end
      processed << current_hash

      #puts "Processed: #{processed.map{|m| [m[:message].id, m[:message].key] }.inspect}"
      # Creating locations
      processed.each do |m_hash|
        messages = m_hash.map{|_, m| m[:message] }
        puts "Processing: #{messages.map{|m| [m.id, m.key]}.inspect}"
        dubls = m_hash.map{|_, m| m[:dubls].map{|mm| mm.id} }.flatten
        puts "Dubls: #{dubls.inspect}"

        UserMessagesAnalyzer.reprocess_messages messages

        dubls = m_hash.map{|_, m| m[:dubls].map{|mm| mm.id} }.flatten
        UserMessage.update_all({ is_dubl: true }, { id: dubls })
      end
    end
  end

  def get_user_location_by_message(message)
    if message.polling_place_internal_id.present?
      return message.user_location = message.user.locations.where(external_id: message.polling_place_internal_id).first
    else
      user = message.user
      region = Region.find_by_external_id message.polling_place_region

      return nil unless region

      commission = user.commissions.where(number: message.polling_place_id, region_id: region.id).first

      return nil unless commission

      return user.locations.find_by_commission_id commission.id
    end
  end

  def process_media_items(message)
    message.media_items.each do |item|
      if item.timestamp > Time.now + 100.years || !item.is_processed?
        item.update_column(:timestamp, Time.at(item.timestamp.to_i / 1000))

        begin
          MediaItemAnalyzer.new(item).process!(force: true)
        rescue => e
          puts "Message: #{message.inspect}"
          puts "e: #{e}"

          Airbrake.notify(
                          error_class:    "Fix timestamp Error/API Error",
                          error_message:  "#{e.message}",
                          parameters:     { media_item: item.inspect }
                      )
        end
      end
    end
  end

end