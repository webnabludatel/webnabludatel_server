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
      user = @user_message.user

      # 1. Getting all messages for "user location" (in device app terms) associated with the current +@user_message+
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

      # 2. Do we have enough message to find a commission?
      return if (REQUIRED_COMMISSION_KEYS - current_batch.keys).length > 0

      # 2. Finding a +user_location+ for a +current_batch+. If it is present updating it, otherwise create it if it's possible
      # TODO: Add pg_advisory_lock to prevent creating two same locations or race conditions on editing a location.
      location = REQUIRED_COMMISSION_KEYS.inject(user.locations) do |result, key|
        result.where(key: key)
        result
      end.first

      location_attributes = current_batch.inject({}) do |result, message|
        result[message.key] = message.value
        result
      end
      location_attributes.delete "district_banner_photo"
      message_for_coordinates = current_batch["district_banner_photo"] || current_batch.first
      location_attributes["latitude"] = message_for_coordinates.lat
      location_attributes["longitude"] = message_for_coordinates.lng

      if location
        location.attributes = location_attributes
      else
        location = user.locations.new location_attributes
      end

      location.user_message = current_batch["district_banner_photo"] if current_batch["district_banner_photo"]
      location.save!
    end

    def process_checklist_item

    end

end