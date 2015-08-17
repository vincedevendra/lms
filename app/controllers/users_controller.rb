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

  def new_professor
    @user = User.new
  end

  def create_professor
    if params[:key] == ENV["professor_key"]
      @user = User.new(user_params.merge!(professor: true))
      if @user.save
        flash[:success] = "Welcome, Prof. #{@user.last_name}!"
        redirect_to sign_in_path
      else
        render 'new_professor'
      end
    else
      flash[:danger] = "The key you entered was incorrect. Please try again."
      render 'new_professor'
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :college_id)
    end
end
