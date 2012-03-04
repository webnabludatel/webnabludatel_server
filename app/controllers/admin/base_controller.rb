# encoding: utf-8

class Admin::BaseController < ApplicationController
  before_filter :authenticate_user!

  def index

  end

end