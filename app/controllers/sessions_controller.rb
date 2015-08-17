class SessionsController < ApplicationController
  before_action :current_user_redirect

  def create
    @user = User.find_by(email: params[:email])
    
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to root_path
    else
      flash.now[:danger] = "Please check your email and password and try again."
      render 'new'
    end
  end
end