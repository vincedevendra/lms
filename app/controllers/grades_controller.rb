class GradesController < ApplicationController
  before_action :no_current_user_redirect
  before_action :unless_instructor_redirect
  before_action :get_submission, except: :index
  before_action :get_assignment_and_course, except: [:create, :edit]
  before_action :redirect_unless_instructor_owns_course
  respond_to :js, :html

  def index
    @student_submissions = @course.student_submission_trackers(@assignment)
    @assignment = @assignment.decorate
  end

  def create
    @submission.update(grade: params[:grade])
  end

  private

  def get_submission
    @submission = Submission.find(params[:submission] || params[:id])
  end

  def redirect_unless_instructor_owns_course
    unless @course.try(:instructor) == current_user ||
      @submission.try(:assignment).try(:course).try(:instructor) == current_user
      flash[:warning] = 'Access denied'
      redirect_to root_path
    end
  end
end
