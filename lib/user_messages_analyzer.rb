# encoding: utf-8

class UserMessagesAnalyzer < Analyzer

  def self.reprocess_messages(messages)
    return unless messages.present?
    analyzer = UserMessagesAnalyzer.new messages.first
    analyzer.send :process_commission, messages
  end

  def self.reprocess_delayed(user_location)
    user = user_location.user

    messages = if user_location.external_id.present?
      user.user_messages.delayed.where(polling_place_internal_id: user_location.external_id)
    else
      user.user_messages.delayed.where(polling_place_region: user_location.commission.region.external_id).where(polling_place_id: user_location.commission.number)
    end

    messages.each do |message|
      UserMessagesAnalyzer.new(message).process!
      message.media_items.each do |media|
        MediaItemAnalyzer.new(media).process!
      end
    end
  end

  def run_processors
    return if @message.is_processed? && !@message.is_delayed? && !options[:force]
    
    case @message.key
      when *COMMISSION_KEYS
        process_commission
      when *SOS_KEYS
        process_sos
      when *PROFILE_KEYS
        process_profile
      when *RESULT_PHOTO_KEYS
        process_protocol_photo_messages
      when *OBSERVER_STATUS_KEYS
        process_observer_status
      when *OFFICIAL_OBSERVER_KEYS
        process_official_observer
      else
        check_list_item = CheckListItem.find_by_name @message.key
        if check_list_item
          process_checklist_item(check_list_item)
        else
          Airbrake.notify(
              error_class:    "API Error",
              error_message:  "Unknown message key: #{@message.key}",
              parameters:     { payload: @message.inspect }
          )
          return
        end
    end

    @message.update_column :is_processed, true
  end

  protected
    # For now we do believe that we have all commissions in the DB
    def process_commission(messages = nil)
      # 1. Getting all messages for "user location" (in device app terms) associated with the current +@user_message+
      current_batch = if messages
        messages.inject({}) do |result, message|
          result[message.key] = message
          result
        end
      else
        get_location_messages_for_current
      end

      # 2. Do we have enough messages to find a commission?
      return if (REQUIRED_COMMISSION_KEYS - current_batch.keys).length > 0

      # 3.1 Finding a commission, if there is no such commission creating not-system pending commission.
      region = Region.find_by_external_id! current_batch["district_region"].value
      commission = region.commissions.where(kind: current_batch["district_type"].value, number: current_batch["district_number"].value).first
      location = @message.user_location

      if commission && !location
        location = @user.locations.where(commission_id: commission.id).first
      else
        commission = region.commissions.new kind: current_batch["district_type"].value, number: current_batch["district_number"].value
        commission.is_system = false
        commission.save!
      end

      # 3.2 Updating +user_location+ +commission+
      if location && location.commission != commission
        location.commission = commission
        location.status = "pending"
      end

      location = @user.locations.new unless location

      message_for_coordinates = current_batch["district_banner_photo"] || current_batch.first.second
      location.latitude = message_for_coordinates.latitude
      location.longitude = message_for_coordinates.longitude
      location.external_id = message_for_coordinates.polling_place_internal_id
      location.commission = commission if location.new_record?
      location.chairman = current_batch["district_chairman"].value if current_batch["district_chairman"]
      location.secretary = current_batch["district_secretary"].value if current_batch["district_secretary"]

      location.save!

      photo_message = current_batch["district_banner_photo"]
      if photo_message && photo_message.media_items.present?
        processed_items = location.photos.where(media_item_id: photo_message.media_items.map(&:id))
        media_items = photo_message.media_items.reject{|media_item| processed_items.include? media_item.id }

        media_items.each do |media_item|
          photo = location.photos.build
          photo.media_item = media_item
          photo.remote_image_url = media_item.url
          photo.timestamp = media_item.timestamp

          photo.save!
        end
      end

      current_batch.each do |_,message|
        message.update_column :user_location_id, location.id
      end

    end

    def process_checklist_item(check_list_item)
      unless parsed_location
        @message.update_column :is_delayed, true
        return
      end

      # Fixing old api bug
      message_value = if @message.key == "koib_nonelectricity_problem" && @message.old_api?
        @message.value == "false" ? "true" : "false"
      else
        @message.value
      end

      watcher_report = parsed_location.watcher_reports.find_by_key @message.key

      if watcher_report && watcher_report.timestamp > @message.timestamp && watcher_report.timestamp < Time.now + 100.years
        puts "OLD MESSAGE: Message: #{@message.id}"
        return
      end

      watcher_report = parsed_location.watcher_reports.new key: @message.key unless watcher_report
      watcher_report.user = @user
      
      if message_value == "0" || message_value == "undef"
        puts "setting undef"
        watcher_report.value = nil
      else  
        watcher_report.value = message_value
      end
      
      watcher_report.timestamp = @message.timestamp
      watcher_report.latitude = @message.latitude
      watcher_report.longitude = @message.longitude
      watcher_report.check_list_item = check_list_item
      watcher_report.has_photos = check_list_item.kind.photo?
      watcher_report.has_videos = check_list_item.kind.video?

      if watcher_report.save
        @message.watcher_report_id = watcher_report.id
      else
        @message.processing_errors.push(*watcher_report.errors.full_messages)
      end

      @message.is_delayed = false
      @message.save
    end

    def process_sos
      if @message.polling_place_region.present? ||
          @message.polling_place_id.present? ||
          @message.polling_place_internal_id &&
          parsed_location.nil?

        @message.update_column :is_delayed, true

        return
      end

      if @message.key == "sos_report_text"
        sos_message = @user.sos_messages.find_by_user_message_id @message.id
        sos_message = @user.sos_messages.new(body: @message.value, latitude: @message.latitude, longitude: @message.longitude, user_message: @message) unless sos_message
        sos_message.location = parsed_location
        sos_message.timestamp = @message.timestamp
        sos_message.save!
      end

      @message.update_column :is_delayed, false
    end

    def process_profile
      user = @message.user
      user[@message.key] = @message.value
      unless user.save
        @message.processing_errors.push(*user.errors.full_messages)
        @message.save
      end
    end

    def process_protocol_photo_messages
      if parsed_location
        @message.update_column :user_location_id, parsed_location.id
        @message.update_column :is_delayed, false
      else
        @message.update_column :is_delayed, true
      end
    end

    def process_observer_status
      user = @message.user
      user.set_watcher_kind @message.value
      user.save!
    end

    def process_official_observer
      # Doing nothing.
    end

  private
      def get_location_messages_for_current
        if @message.polling_place_internal_id.present? && !options[:force_old_api]
          # NEW API
          messages = @user.user_messages.where(polling_place_internal_id: @message.polling_place_internal_id).where(key: COMMISSION_KEYS).order(:timestamp)

          current_batch = messages.inject({}) do |result, message|
            result[message.key] = message
            result
          end

          current_batch
        else
           # OLD API
          get_messages_for_current(COMMISSION_KEYS)
        end
      end
end