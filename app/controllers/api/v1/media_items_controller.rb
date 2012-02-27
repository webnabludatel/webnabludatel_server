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
    @user_message = current_user.user_messages.find(params[:message_id])
    @message = @user_message.device_messages.build(kind: 'media_item', device_id: params['device_id'], payload: params['payload'])

    if @message.save
      render_result media_item_id: @message.media_item.id
    else
      render_error @message.errors.full_messages
    end
  end

  def update
    @media_item = current_user.media_items.find(params[:id])
    @user_message = @media_item.user_message
    @message = @user_message.device_messages.build(kind: 'media_item', device_id: params['device_id'], payload: params['payload'])

    if @message.save
      render_result media_item_id: @media_item.id
    else
      render_error @message.errors.full_messages
    end
  end
end