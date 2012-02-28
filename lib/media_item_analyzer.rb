# encoding: utf-8

class MediaItemAnalyzer

  def initialize(media_item)
    @media_item = media_item
  end

  def process!
    case @media_item.user_message.key
      when "official_observer"
        process_observer_referral_photo
      when "district_banner_photo"
        process_user_location_photo
      when "sos_report_photo"
        process_sos_photo
      end
    end
  end

  protected
    def process_observer_referral_photo
      user = @media_item.user_message.user

      referral = user.referral || WatcherReferral.new
      referral.user = user

      referral.save!

      referral_photo = referral.referral_photos.find_or_initialize_by_media_item_id @media_item.id
      referral_photo.remote_image_url = @media_item.url
      referral_photo.timestamp = @media_item.timestamp

      referral_photo.save!

      user.update_attribute :watcher_status, "pending" if user.watcher_status.none?
    end

    def process_user_location_photo
      user_message = @media_item.user_message
      location = user_message.user_location

      return unless location

      return if location.photos.where(media_item_id: @media_item.id).exists?

      photo = location.photos.build
      photo.media_item = @media_item
      photo.remote_image_url = @media_item.url
      photo.timestamp = @media_item.timestamp

      photo.save!
    end

    def process_sos_photo
      user = @media_item.user

      user_sos_messages = get_sos_messages_for_current
      sos_message = user.sos_messages.where(user_message_id: user_sos_messages["sos_report_text"].id).first

      return if sos_message.photos.where(media_item_id: @media_item.id).exists?

      photo = sos_message.photos.build
      photo.media_item = @media_item
      photo.remote_image_url = @media_item.url
      photo.timestamp = @media_item.timestamp

      photo.save!
    end

  private
    def get_sos_messages_for_current
      user = @media_item.user

      messages = user.user_messages.where(key: UserMessagesAnalyzer::SOS_KEYS).order(:timestamp)

      message_batches, tmp_batch, current_batch = [], {}, {}
      messages.each do |message|
        if tmp_batch[message.key]
         message_batches << tmp_batch
         tmp_batch = { message.key => message }
        else
         tmp_batch[message.key] = message
        end

        current_batch = tmp_batch if message == @media_item.user_message
      end
      message_batches << tmp_batch

      current_batch
    end
end