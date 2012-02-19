class SplashSubscribersController < ApplicationController
  skip_before_filter :authenticate
  
  def create
    @subscriber = SplashSubscriber.create email: params[:email]

    render template: "home/index"
  end

end