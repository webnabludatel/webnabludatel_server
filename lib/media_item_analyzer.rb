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
      Rails.logger.info ">> PROCESS PHOTO: #{@media_item.inspect}"
      user_message = @media_item.user_message
      location = user_message.user_location

      Rails.logger.info ">> #{location.inspect}"

      return unless location

      Rails.logger.info ">> #{location.photos.where(media_item_id: @media_item.id).exists?.inspect}"

      return if location.photos.where(media_item_id: @media_item.id).exists?

      photo = location.photos.build

      Rails.logger.info ">>1 #{photo.inspect}"

      photo.media_item = @media_item

      Rails.logger.info ">>2 #{photo.inspect}"

      photo.image.remote_image_url = media_item.url

      Rails.logger.info ">>3 #{photo.inspect}"
      Rails.logger.info ">>4 #{media_item.timestamp.inspect} - #{media.item.timestamp.class.name}"

      photo.timestamp = media_item.timestamp

      Rails.logger.info ">>5 #{photo.inspect}"

      photo.save!

      Rails.logger.info ">>6 #{photo.inspect}"
    end

end