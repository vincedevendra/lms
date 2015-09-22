class InstructorsController < UsersController
  def new
    @user = User.new
  end

  def create
    if params[:key] == ENV["instructor_key"]
      @user = User.new(user_params.merge!(instructor: true))
      if @user.save
        flash[:success] = "Welcome, Prof. #{@user.last_name}! Please log in"
        redirect_to sign_in_path
      else
        render 'new'
      end
    else
      flash[:danger] = "The key you entered was incorrect. Please try again."
      render 'new'
    end
  end
end
