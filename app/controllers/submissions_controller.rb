class SubmissionsController < ApplicationController
  before_action :no_current_user_redirect
  before_action :get_assignment_and_course
  before_action :redirect_unless_instructor_owns_course, only: :show 
  before_action :get_assignments
  before_action :get_submission, except: :create
  before_action :redirect_if_not_enrolled, except: :show
  before_action :handle_no_file_chosen, except: :show

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

  def show
    render 'show' and return if @submission.box_view_id? 
    uploader = SubmissionBoxViewUploader.new(@submission) 
    uploader.upload_to_box_view

    if uploader.success?
      @submission.update_attribute(:box_view_id, uploader.box_view_id)
    end
  end

  def update
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

  def get_submission
    @submission = Submission.find(params[:id])
  end
end
