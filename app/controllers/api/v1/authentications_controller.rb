# encoding: utf-8

class Api::V1::AuthenticationsController < Api::V1::BaseController
  skip_before_filter :authenticate_user!

  before_filter :check_existing_authentication

  def create
    @auth = Authentication.register_device!(params[:device_id])

    if @auth.errors.blank?
      render_result secret: @auth.secret, user_id: @auth.user.id
    else
      render_error @auth.errors.full_messages
    end
  end

  protected

  # TODO: жесточайшая дырень в безопасности
  def check_existing_authentication
    @auth = Authentication.for_device(params[:device_id])

    render_result secret: @auth.secret, user_id: @auth.user.id if @auth
  end
end