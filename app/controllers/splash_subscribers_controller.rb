class SplashSubscribersController < ApplicationController
  def create
    @subscriber = SplashSubscriber.create email: params[:email]

    render template: "home/index"
  end
end