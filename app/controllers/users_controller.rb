class UsersController < ApplicationController
  before_action :current_user_redirect

  def new
    if params[:token]
      invitation = Invitation.find_by(token: params[:token])
      @invitation_token = invitation.token
      @invitation_email = invitation.email
    end

    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      token = params[:user][:token]
      if token.present?
        invitation = Invitation.find_by(token: token)
        Enrollment.create(student: @user, course: invitation.course)
        flash[:info] = "You have been enrolled in #{invitation.course.decorate.display_title}. Log in to get started."
      end

      flash[:success] = "Thanks for registering, #{@user.full_name}!"
      redirect_to sign_in_path
    else
      render 'new'
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :student_id)
    end
end
