class UsersController < ApplicationController

  skip_before_filter :beta_authenticate

  def show
    @user = User.find params[:id]
  end

end