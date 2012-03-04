class Admin::UserMessagesController < Admin::BaseController
  def index
    @search = UserMessage.search(params[:search])
    @user_messages = @search.order("id desc").page(params[:page]).per(50)
  end
end