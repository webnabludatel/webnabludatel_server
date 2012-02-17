# encoding: utf-8

class Api::V1::MessagesController < Api::V1::BaseController

  def create
    @message = current_user.device_messages.build(message: params[:payload])

    if @message.save
      render json: { status: :ok, message_id: @message.id }
    else
      render json: { status: :error, msg: @message.errors.full_messages.join("\n") }
    end
  end

  def update
    @message = DeviceMessage.find params[:id]

    if @message.update_attributes(message: params[:payload])
      render json: { status: :ok, message_id: @message.id }
    else
      render json: { status: :error, msg: @message.errors.full_messages.join("\n") }
    end
  end

end