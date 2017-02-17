class SessionsController < ApplicationController
  before_action :current_user_redirect, only: :create

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

  def destroy
    session[:user_id] = nil
    redirect_to sign_in_path
  end
end
