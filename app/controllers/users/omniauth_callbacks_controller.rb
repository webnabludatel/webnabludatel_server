# encoding: utf-8

##
## Пока мне почему-то не захотелось ломать дефолтные роуты, которые делает Devise, поэтому контроллер немного странный.
##
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    generic_callback
  end

  def vkontakte
    generic_callback
  end

  private

  def generic_callback
    omniauth = request.env['omniauth.auth']
    provider_name = omniauth['provider'].camelize

    if user_signed_in?
      current_user.register_omniauth(omniauth)
      redirect_to edit_user_registration_path, notice: I18n.t('devise.omniauth_callbacks.linked', :kind => provider_name)
    else
      user = User.find_or_create_by_omniauth!(omniauth)
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', :kind => provider_name
      sign_in_and_redirect user
    end
  end
end