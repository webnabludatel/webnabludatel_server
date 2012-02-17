# encoding: utf-8

class Api::V1::MessagesController < Api::V1::BaseController

  # params[:payload]
  #
  # {
  #   "key" : ключ элемента чеклиста,
  #   "value" : значение элемента чеклиста,
  #   "lat" : широта точки отправки сообщения,
  #   "lng" : долгота точки отправки сообщения,
  #   "timestamp" : UNIX-таймстемп момента внесения данных пользователем
  # }
  def create
    @message = current_user.device_messages.build(message: params[:payload])

    if @message.save
      render_result(message_id: @message.id)
    else
      render_error(@message.errors.full_messages)
    end
  end

  def update
    @message = DeviceMessage.find params[:id]

    if @message.update_attributes(message: params[:payload])
      render_result(message_id: @message.id)
    else
      render_error(@message.errors.full_messages)
    end
  end

end