# encoding: utf-8

class MediaItemAnalyzer < Analyzer

  def initialize(media_item)
    @media_item = media_item
    @message = media_item.user_message
    @user = media_item.user
  end

  def run_processors
    return if @message.is_delayed? || @media_item.is_processed? && !options[:force]

    case @message.key
      when "official_observer"
        process_observer_referral_photo
      when "district_banner_photo"
        process_user_location_photo
      when "sos_report_photo"
        process_sos_photo
      when "sos_report_video"
        process_sos_video
      when "protocol_photo"
        process_protocol_photo
      when "protocol_copy_photo"
        process_protocol_copy_photo
      else
        check_list_item = CheckListItem.find_by_name @message.key
        if check_list_item && check_list_item.kind.photo?
          process_check_list_photo
        elsif check_list_item  && check_list_item.kind.video?
          process_check_list_video
        else
          Airbrake.notify(
              error_class:    "API Error",
              error_message:  "Unknown message key: #{@message.key}",
              parameters:     { payload: @message.inspect }
          )
          return
        end
    end

    @media_item.update_column :is_processed, true
  end

  protected
    def process_observer_referral_photo
      referral = @user.referral || WatcherReferral.new
      referral.user = @user

      referral.save!

      referral_photo = referral.referral_photos.find_or_initialize_by_media_item_id @media_item.id
      referral_photo.remote_image_url = @media_item.url
      referral_photo.timestamp = @media_item.timestamp

      referral_photo.save!

      @user.update_attribute :watcher_status, "pending" if @user.watcher_status.none?
    end

    def process_user_location_photo
      location = @message.user_location

      return unless location

      photo = location.photos.find_or_initialize_by_media_item_id @media_item.id
      photo.remote_image_url = @media_item.url
      photo.timestamp = @media_item.timestamp

      photo.save!
    end

    def process_sos_photo
      user_sos_messages = get_messages_for_current(SOS_KEYS)
      sos_message = @user.sos_messages.where(user_message_id: user_sos_messages["sos_report_text"].id).first

      photo = sos_message.photos.find_or_initialize_by_media_item_id @media_item.id
      photo.remote_image_url = @media_item.url
      photo.timestamp = @media_item.timestamp

      photo.save!
    end

    def process_sos_video
      user_sos_messages = get_messages_for_current(SOS_KEYS)
      sos_message = @user.sos_messages.where(user_message_id: user_sos_messages["sos_report_text"].id).first

      video = sos_message.videos.find_or_initialize_by_media_item_id @media_item.id
      video.url = @media_item.url
      video.timestamp = @media_item.timestamp

      video.save!
    end

    def process_check_list_photo
      watcher_report = @message.watcher_report
      photo = watcher_report.photos.find_or_initialize_by_media_item_id @media_item.id
      photo.remote_image_url = @media_item.url
      photo.timestamp = @media_item.timestamp

      photo.save!
    end

    def process_check_list_video
      watcher_report = @message.watcher_report
      video = watcher_report.videos.find_or_initialize_by_media_item_id @media_item.id
      video.url = @media_item.url
      video.timestamp = @media_item.timestamp

      video.save!
    end

    def process_protocol_photo
      location = @message.user_location
      photo = location.protocol_photos.find_or_initialize_by_media_item_id @media_item.id
      photo.remote_image_url = @media_item.url
      photo.timestamp = @media_item.timestamp

      photo.save!
    end

    def process_protocol_copy_photo
      location = @message.user_location
      photo = location.protocol_photo_copies.find_or_initialize_by_media_item_id @media_item.id
      photo.remote_image_url = @media_item.url
      photo.timestamp = @media_item.timestamp

      photo.save!
    end
end