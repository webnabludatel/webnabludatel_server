# encoding: utf-8

class Api::V1::MessagesController < Api::V1::Base

  def create
    @message = current_user.device_messages.build(message: params[:message])

    if @message.save
      render json: { status: "OK", message_id: @message.id }
    else
      render json: { status: "ERROR", msg: @message.errors.full_messages.join("\n") }
    end
  end

  def update
    @message = DeviceMessage.find params[:id]

    if @message.update_attributes message: params[:message]
      render json: { status: "OK", message_id: @message.id }
    else
      render json: { status: "ERROR", msg: @message.errors.full_messages.join("\n") }
    end
  end

end