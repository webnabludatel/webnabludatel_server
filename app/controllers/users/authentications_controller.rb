# encoding: utf-8

class Users::AuthenticationsController < Devise::OmniauthCallbacksController
  before_filter :authenticate_user!, except: :create

  def create
    omniauth = request.env['omniauth.auth']
    provider_name = omniauth['provider'].camelize

    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'].to_s, omniauth['uid'].to_s)

    if authentication
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', :kind => provider_name
      sign_in_and_redirect(:user, authentication.user)
    elsif signed_in?
      current_user.apply_omniauth(omniauth)
      if current_user.save
        redirect_to edit_user_registration_path, notice: I18n.t('devise.omniauth_callbacks.linked', :kind => provider_name)
      else
        redirect_to edit_user_registration_path, error: I18n.t('devise.omniauth_callbacks.link_failed', :kind => provider_name)
      end
    else
      user = User.find_by_email(omniauth['info']['email']) || User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', :kind => provider_name
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    redirect_to edit_user_registration_path, notice: "Successfully removed your #{@authentication.provider.titleize} account link"
  end
end