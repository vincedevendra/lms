class AppMailer < ActionMailer::Base
  def enrollment_notification(user, course)
    @user = user
    @course = course
    mail from: 'notices@gradebook.com', to: recipient(user.email), subject: 'Enrollment Notification'
  end

  private

  def recipient(email)
    Rails.env == 'staging' ? 'vincedevendra@gmail.com' : email
  end
end
