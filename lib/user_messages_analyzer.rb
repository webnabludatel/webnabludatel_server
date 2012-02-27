# encoding: utf-8

class UserMessagesAnalyzer

  COMMISSION_KEYS = %W(district_region district_type district_number district_chairman district_secretary district_banner_photo)
  REQUIRED_COMMISSION_KEYS = %W(district_region district_type district_number)

  CHECKLIST_KEYS= %W()

  def initialize(user_message)
    @user_message = user_message
  end

  def process!
    if COMMISSION_KEYS.include? @user_message.key
      process_commission
    elsif CHECKLIST_KEYS.include? @user_message.key
      process_checklist_item
    end
  end

  protected
    # For now we do believe that we have all commissions in the DB
    def process_commission
      Rails.logger.info "===============: #{@user_message.key} :==============="
      user = @user_message.user

      # 1. Getting all messages for "user location" (in device app terms) associated with the current +@user_message+
      current_batch = get_location_messages_for_current
      #Rails.logger.info "> current_batch: #{current_batch.inspect}"
      current_batch.each {|m| Rails.logger.info ">> #{m.key}" }

      # 2. Do we have enough messages to find a commission?
      return if (REQUIRED_COMMISSION_KEYS - current_batch.keys).length > 0

      # 3. Finding a +user_location+ for a +current_batch+. If it is present updating it, otherwise create it if it's possible
      # TODO: Add pg_advisory_lock to prevent creating two same locations or race conditions on editing a location.
      location = REQUIRED_COMMISSION_KEYS.inject(user.locations) do |result, key|
        result.where(key: key)
        result
      end.first

      Rails.logger.info "> location: #{location.inspect}"

      # 3.1 Finding a commission, if there is no such commission creating not-system pending commission.
      region = Region.find_by_external_id! current_batch["district_region"].value
      commission = region.commissions.where(kind: current_batch["district_type"].value, number: current_batch["district_number"].value).first

      unless commission
        commission = region.commissions.new kind: current_batch["district_type"].value, number: current_batch["district_number"].value
        commission.is_system = false
        commission.save!
      end

      Rails.logger.info "> commission: #{commission.inspect}"

      # 3.2 Updating +user_location+ +commission+
      if location && location.commission != commission
        location.commission = commission
        location.status = "pending"
      end

      location = user.locations.new unless location

      message_for_coordinates = current_batch["district_banner_photo"] || current_batch.first
      location.latitude = message_for_coordinates.latitude
      location.longitude = message_for_coordinates.longitude
      location.external_id = message_for_coordinates.polling_place_internal_id
      location.commission = commission if location.new_record?
      location.chairman = current_batch["district_chairman"].value if current_batch["district_chairman"]
      location.secretary = current_batch["district_secretary"].value if current_batch["district_secretary"]

      location.save!

      Rails.logger.info "> location: #{location.inspect}"

      # 4 Setting location photos
      photo_message = current_batch["district_banner_photo"]
      if photo_message
        photo_message.user_location = location
        photo_message.save!
      end

      if photo_message && photo_message.media_items.present?
        processed_items = location.photos.where(media_item_id: photo_message.media_items.map(&:id))
        media_items = photo_message.media_items.reject{|media_item| processed_items.include? media_item.id }

        media_items.each do |media_item|
          photo = location.photos.build
          photo.media_item = media_item
          photo.image.remote_image_url = media_item.url
          photo.timestamp = media_item.timestamp

          photo.save!
        end
      end

    end

    def process_checklist_item
    end

    private
      def get_location_messages_for_current
        user = @user_message.user

        if @user_message.polling_place_internal_id.present? # NEW API
          messages = user.user_messages.where(polling_place_internal_id: @user_message.polling_place_internal_id).where(key: COMMISSION_KEYS).order(:timestamp)

          current_batch = messages.inject({}) do |result, message|
            result[message.key] = message
            result
          end
        else # OLD API
          messages = user.user_messages.where(key: COMMISSION_KEYS).order(:timestamp)

          message_batches, tmp_batch, current_batch = [], {}, {}
          messages.each do |message|
            if tmp_batch[message.key]
              message_batches << tmp_batch
              tmp_batch = { message.key => message }
            else
              tmp_batch[message.key] = message
            end

            current_batch = tmp_batch if message == @user_message
          end
          message_batches << tmp_batch
        end

        current_batch
      end
end