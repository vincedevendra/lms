class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  def current_user_redirect
    redirect_to root_path if current_user
  end

  def no_current_user_redirect
    redirect_to sign_in_path unless current_user
  end

  def unless_instructor_redirect
    redirect_to root_path unless current_user && current_user.instructor?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
