class CoursesController < ApplicationController

  before_action :unless_instructor_redirect
  before_action :find_course, only: [:edit, :update, :destroy]
  respond_to :js, :html

  def index
    @courses = CourseDecorator.decorate_collection(current_user.courses_owned)
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)

    if @course.valid?
      current_user.courses_owned << @course
      @course.save
      flash.now[:success] = "#{@course.title} has been saved."
    end
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
    params.require(:course).permit(:title, :code, :location, {meeting_days: []}, :start_time, :end_time, :notes)
  end

  def find_course
    @course = Course.find(params[:id])
  end
end
