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

      referral_photo.save!

      user.update_attribute :status, "pending" if user.status.none?
    end

    def process_user_location_photo
      user_message = @media_item.user_message
      location = user_message.user_location

      if location
        location.remote_image_url = @media_item.url
        location.save!
      end
    end

  private
    # We catch all exceptions in the +process+ method because bugs it it should not fail creating and logging data from
    # users and so +log+ method is used for sending exception data to the Airbrake app.
    def log

    end
end