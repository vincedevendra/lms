class UsersController < ApplicationController
  before_action :current_user_redirect

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = "Thanks for registering, #{@user.full_name}!"
      redirect_to sign_in_path
    else
      render 'new'
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :college_id)
    end
end
