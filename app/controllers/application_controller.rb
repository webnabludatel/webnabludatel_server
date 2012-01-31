# encoding: utf-8

class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :set_locale
  before_filter :check_user_validity

  before_filter :set_mobile_preferences
  before_filter :prepend_view_path_if_mobile

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # enforce user to set the email if he signed up through Facebook or Vkontakte
  def check_user_validity
    redirect_to edit_user_registration_path if current_user && current_user.email.blank? && request.fullpath !~ /^.users/
  end

  private

  def is_mobile_device?
    request.user_agent.to_s.downcase =~ Regexp.new('palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                                                       'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                                                       'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                                                       'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                                                       'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                                                       'mobile'
    )
  end

  helper_method :is_mobile_device?

  def set_mobile_preferences

    # Check for user request - mobile or standart view
    if params[:mobile]
      params[:mobile] == "1" ? session[:mobile_view] = 1 : session[:mobile_view] = 0
    end

    # Switch format depending on user preferences or type of device
    if session[:mobile_view] == 1 || is_mobile_device?
      request.format = :mobile
    else
      request.format = :html
    end
  end

  def prepend_view_path_if_mobile
    if request.format == :mobile
      prepend_view_path Rails.root + 'app' + 'mobile_views'
    end
  end

end
