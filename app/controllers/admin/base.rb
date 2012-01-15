class Admin::Base < ApplicationController
  before_filter :authenticate_user!

end