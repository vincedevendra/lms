class GradesController < ApplicationController
  before_action :no_current_user_redirect
  before_action :unless_instructor_redirect
  before_action :get_assignment_and_course
  before_action :get_grade, only: [:edit, :update]
  before_action :redirect_unless_instructor_owns_course
  respond_to :js, :html

  def index
    if @assignment.submission_required?
      @students = @course.student_submission_trackers(@assignment)
    else
      @students = @course.students.includes(:grades)
    end

    @assignment = @assignment.decorate
  end

  def create
    @student = User.includes(:courses).find(params[:grade][:student_id])
    unless @student.courses.include?(@course)
      flash[:danger] = "This student is not enrolled in your course."
      redirect_to course_assignment_grades_path
    else
      @grade = Grade.new(grade_params.merge!(assignment_id: @assignment.id, student_id: @student.id))
      @grade.save
    end
  end

  def update
    @grade.update(grade_params)
    render 'create'
  end

  private

  def redirect_unless_instructor_owns_course
    unless @course.instructor == current_user
      flash[:warning] = 'Access denied'
      redirect_to root_path
    end
  end

  def grade_params
    params.require(:grade).permit(:points, :student_id)
  end

  def get_grade
    @grade = Grade.find(params[:id])
  end
end
