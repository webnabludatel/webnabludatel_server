# encoding: utf-8

class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :beta_authenticate

  before_filter :set_locale
  before_filter :set_mobile_preferences
  # before_filter :prepend_view_path_if_mobile

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def beta_authenticate
    public_controllers = [HomeController, SplashSubscribersController, Api::V1::BaseController]
    if Rails.env.production? && !public_controllers.map {|c| self.kind_of?(c)}.inject {|c, a| c || a}
      authenticate_or_request_with_http_basic do |username, password|
        username == "webnabludatel" && password == Settings.beta.password
      end
    end
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

    # Check for user request - mobile or standard view
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