class EnrollmentsController < ApplicationController
  respond_to :js, :html

  def new
    @course = Course.find(params[:course_id])
  end

  def destroy
    course = Course.select(:id, :title).find(params[:course_id])
    Enrollment.find_by(student: current_user, course: course).delete

    flash[:danger] = "You have been disenrolled from #{course.title}."
    redirect_to root_path
  end

  def create
    @course = Course.find(params[:course_id]).decorate
    if params[:student_emails]
      student_emails = params[:student_emails].split(',').map(&:strip)
    else
      flash.now[:danger] = "Please enter valid emails in the field below."
      render 'create'
      return
    end

    valid_emails = student_emails.select { |email| email =~ VALID_EMAIL_REGEX }

    invalid_emails = student_emails - valid_emails

    if invalid_emails.any?
      formatted_emails = invalid_emails.join(", ")
      flash.now[:danger] = "The following emails were not validly formatted:<br/> #{formatted_emails}".html_safe
    end

    registered_students = valid_emails.map{ |email| User.find_by(email: email) }
    registered_students.delete(nil)

    enrolled_students = registered_students.select do |student|
      student.courses.include?(@course)
    end

    if enrolled_students.any?
      formatted_emails = enrolled_students.map(&:email).join(', ')
      flash.now[:warning] = "The following students are already enrolled in your course:<br/> #{formatted_emails}".html_safe
    end

    unregistered_emails = valid_emails - registered_students.map(&:email)

    if unregistered_emails.any?
      flash.now[:info] = "An invitation to join GradeBook has been sent to the following email addresses.  They will be enrolled in your course at registration:</br>#{unregistered_emails.join(", ")}".html_safe
    end

    registered_students = registered_students - enrolled_students

    if registered_students.any?
      registered_students.each do |student|
        Enrollment.create(course: @course, student: student)
        AppMailer.enrollment_notification(student, @course).deliver
      end

      names = registered_students.map do |student|
        "#{student.first_name} #{student.last_name}"
      end

      formatted_names = names.join(", ")

      flash.now[:success] = "The following students were already registered for GradeBook and have been successfully enrolled in your course:</br> #{formatted_names}".html_safe
    end
  end
end
