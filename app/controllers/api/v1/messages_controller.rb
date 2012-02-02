# encoding: utf-8

class Api::V1::MessagesController < Api::V1::Base

  def create
    @message = DeviceMessage.new message: params[:message]
    @message.user = nil

    if @message.create
      render json: { STATUS: "OK", MESSAGE_ID: @message.id }
    else
      render json: { STATUS: "ERROR", MSG: @message.errors.full_messages.join("\n") }
    end
  end

  def update
    @message = DeviceMessage.find params[:id]

    if @message.update_attributes message: params[:message]
      render json: { STATUS: "OK", MESSAGE_ID: @message.id }
    else
      render json: { STATUS: "ERROR", MSG: @message.errors.full_messages.join("\n") }
    end
  end

end