# encoding: utf-8

class Api::V1::AuthenticationsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!

  before_filter :check_existing_authentication

  def create
    @auth = Authentication.register_device!(params[:device_id], params[:email])

    if @auth.errors.blank? && @auth.user.errors.blank?
      render json: { status: :ok, secret: @auth.secret }
    else
      render json: { status: :error, message: @auth.errors.full_messages.join("\n") }
    end
  end

  protected

  def check_existing_authentication
    @auth = Authentication.for_device(params[:device_id])

    if @auth
      if@auth.user.email == params[:email]
        render json: { status: :ok, secret: @auth.secret }
      else
        render json: { status: :error, message: "invalid email for this device id" }
      end
    end
  end
end