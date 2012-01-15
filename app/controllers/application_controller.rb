# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :check_user_validity

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # enforce user to set the email if he signed up through Facebook or Vkontakte
  def check_user_validity
    redirect_to edit_user_registration_path if current_user && current_user.email.blank?
  end

end
