# encoding: utf-8

class Analyzer
  COMMISSION_KEYS = %W(district_region district_type district_number district_chairman district_secretary district_banner_photo)
  REQUIRED_COMMISSION_KEYS = %W(district_region district_type district_number)

  SOS_KEYS = %W(sos_report_text sos_report_video sos_report_photo)

  PROFILE_KEYS = %W(email first_name middle_name last_name phone)

  OBSERVER_STATUS_KEYS = %W(observer_status)
  OFFICIAL_OBSERVER_KEYS = %W(official_observer)

  RESULT_PHOTO_KEYS = %W(protocol_photo protocol_copy_photo)

  def initialize(message)
    @message = message
    @user = message.user
  end

  protected
    def parsed_location
      @parsed_location ||= if @message.polling_place_internal_id.present?
        get_location_new_api
      elsif @message.polling_place_id.present? && @message.polling_place_region.present?
        get_location_old_api
      end
    end

    def get_messages_for_current(keys = [])
      messages = keys.present? ? @user.user_messages.where(key: keys).order(:timestamp) : @user.user_messages.order(:timestamp)

      message_batches, tmp_batch, current_batch = [], {}, {}
      messages.each do |message|
        if tmp_batch[message.key]
         message_batches << tmp_batch
         tmp_batch = { message.key => message }
        else
         tmp_batch[message.key] = message
        end

        current_batch = tmp_batch if message == @message
      end
      message_batches << tmp_batch

      current_batch
    end

  private
    def get_location_old_api
      region = Region.find_by_external_id @message.polling_place_region
      return unless region
      commission = @user.commissions.where(region_id: region.id, number: @message.polling_place_id).first
      return unless commission
      commission.user_locations.find_by_user_id @user.id
    end

    def get_location_new_api
      @user.locations.find_by_external_id @message.polling_place_internal_id
    end
end