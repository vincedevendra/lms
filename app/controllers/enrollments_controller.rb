class EnrollmentsController < ApplicationController
  respond_to :js, :html
  before_action :get_course

  def destroy
    Enrollment.find_by(student: current_user, course: @course).delete
    flash[:danger] = "You have been disenrolled from #{@course.title}."
    redirect_to root_path
  end

  def create
    if no_input?
      handle_no_input and return
    end

    enroller = Enroller.new(params[:student_emails], @course)
    enroller.run
    enroller.messages.each do |key, message|
      flash[key] = message
    end
  end

  private

  def get_course
    @course = Course.find(params[:course_id])
  end

  def no_input?
    params[:student_emails].blank?
  end

  def handle_no_input
    flash.now[:danger] = "Please enter valid emails in the field below."
    render 'create'
  end
end
