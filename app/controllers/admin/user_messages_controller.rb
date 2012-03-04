class Admin::UserMessagesController < Admin::BaseController
  def index
    @user_messages = UserMessage.active.order("id DESC").page(params[:page]).per(50)
  end
end