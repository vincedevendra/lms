class CoursesController < ApplicationController
  before_action :unless_instructor_redirect, except: :index
  before_action :find_course, only: [:edit, :update, :show, :destroy]
  before_action :no_current_user_redirect, only: :index
  respond_to :js, :html

  def index
    if current_user.instructor?
      @courses = current_user.courses_owned
    else
      @courses = current_user.courses
    end

    @courses = CourseDecorator.decorate_collection(@courses)
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    @course.instructor = current_user

    if @course.valid?
      @course.save.decorate
      flash.now[:success] = "#{@course.title} has been saved."
    end
  end

  def show
    course = Course
               .includes(assignments: [:submissions], students: [:submissions])
               .find(params[:id])
    course_grade_tracker = GradeTracker::Course.new(course)
    @course = CourseWithGrades.new(course_grade_tracker)
    @assignments = AssignmentDecorator.decorate_collection(@course.assignments)
  end

  def update
    if @course.instructor == current_user && @course.update(course_params)
      flash[:success] = "#{@course.title} has been updated."
    end
  end

  def destroy
    if @course.instructor == current_user
      @course.destroy
    else
      flash.now[:danger] = "You don't own that course"
    end

    redirect_to courses_path
  end

  private

  def course_params
    params.require(:course).permit(:title, :code, :location,
      { meeting_days: [] },
                  :start_time, :end_time, :notes)
  end

  def find_course
    @course = Course.find(params[:id]).decorate
  end
end
