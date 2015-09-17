class AssignmentsController < ApplicationController
  before_action :no_current_user_redirect, only: :index
  before_action :unless_professor_redirect, except: :index
  before_action :find_assignment, only: [:edit, :update, :destroy]

  def index
    @assignments = Assignment.all.order(due_date: :desc)
    @assignment = Assignment.new
  end

  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new(assignment_params)

    if @assignment.save
      flash[:success] = "#{@assignment.title} has been saved"
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
    if @assignment.update(assignment_params)
      flash[:success] = "#{@assignment.title} has been updated."
      redirect_to root_path
    else
      render 'edit'
    end
  end

  def destroy
    @assignment.destroy
    redirect_to root_path
  end

  private
    def assignment_params
      params.require(:assignment).permit(:title, :description, :point_value, :due_date)
    end

    def find_assignment
      @assignment = Assignment.find(params[:id])
    end
end
