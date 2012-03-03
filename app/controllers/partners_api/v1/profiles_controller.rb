# encoding: utf-8

class PartnersApi::V1::ProfilesController < ApplicationController

  skip_before_filter :beta_authenticate
  before_filter :partner_authenticate

  def index
    @users = User.last(10)
    respond_to do |format|
      format.xml { render :xml => @users.to_xml }
    end
  end

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.xml { render :xml => @user }
    end
  end

  private
  def partner_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      # ugly but works
      password && Settings.partners.to_hash[username.to_sym] == password
    end
  end
end
