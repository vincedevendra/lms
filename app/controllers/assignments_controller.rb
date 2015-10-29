class AssignmentsController < ApplicationController
  before_action :no_current_user_redirect, only: :index
  before_action :unless_instructor_redirect, except: :index
  before_action :find_assignment, only: [:edit, :update, :destroy]
  before_action :find_course, only: [:index, :new, :edit, :create, :update]
  respond_to :html, :js

  def index
    @assignments = @course.assignments.order(due_date: :desc)
  end

  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new(assignment_params.merge(course: @course))

    if @assignment.save
      flash.now[:success] = "#{@assignment.title} has been saved."
    end
  end

  def update
    if @assignment.update(assignment_params)
      flash.now[:success] = "#{@assignment.title} has been updated."
    end
  end

  def destroy
    @assignment.destroy
    flash[:danger] = "You have deleted #{@assignment.title}."
    redirect_to root_path
  end

  private

  def assignment_params
    params.require(:assignment).permit(:title, :description, :point_value, :due_date)
  end

  def find_assignment
    @assignment = Assignment.find(params[:id])
  end

  def find_course
    @course = Course.find(params[:course_id]).decorate
  end
end
