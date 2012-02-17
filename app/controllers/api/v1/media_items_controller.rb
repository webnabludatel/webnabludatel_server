# encoding: utf-8

class Api::V1::MediaItemsController < Api::V1::BaseController

  # params[:payload]
  #
  # {
  #   "url": адрес на S3, куда загружен контент создаваемого медиа-файла,
  #   "type": "photo" || "video",
  #   "timestamp": время съемки медиа-файла
  # }
  def create
    @message = current_user.device_messages.find(params[:message_id])
  end
end