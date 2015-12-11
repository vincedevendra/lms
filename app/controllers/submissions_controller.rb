class SubmissionsController < ApplicationController
  before_action :no_current_user_redirect
  before_action :get_assignment_and_course
  before_action :get_assignments
  before_action :redirect_if_not_enrolled
  before_action :handle_no_file_chosen

  def create
    @submission =
      Submission.new(submission_params.merge!(student: current_user,
                                              assignment: @assignment,
                                              submitted_at: Time.now))

    if @submission.save
      @assignment.submissions << @submission
      flash[:success] = 'Your file has been uploaded.'
      redirect_to course_assignments_path(@course)
    else
      flash[:danger] = @submission.errors.full_messages.join(';')
      render 'assignments/index'
    end
  end

  def update
    @submission = Submission.find(params[:id])
    if @submission.update(submission_params.merge!(submitted_at: Time.now))
      flash[:success] = 'Your file has been uploaded.'
      redirect_to course_assignments_path(@course)
    else
      flash[:danger] = @submission.errors.full_messages.join(';')
      render 'assignments/index'
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:submission)
  end

  def handle_no_file_chosen
    unless params[:submission]
      @submission = Submission.find_by(id: params[:id]) || Submission.new
      flash.now[:danger] = 'Please choose a file'
      render 'assignments/index'
      return
    end
  end

  def get_assignments
    @assignments = @course.assignments
  end

  def redirect_if_not_enrolled
    unless Enrollment.find_by(student: current_user, course: @course) || current_user.instructor?
      flash[:warning] = 'Access denied'
      redirect_to root_path
    end
  end
end
