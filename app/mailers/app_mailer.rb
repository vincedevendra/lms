class AppMailer < ActionMailer::Base
  def enrollment_notification(user, course)
    @user = user
    @course = course.decorate
    mail from: 'notices@gradebook.com', to: recipient(user.email), subject: 'Enrollment Notification'
  end

  def invite_to_join_and_enroll(invitation)
    @invitation = invitation
    mail from: 'notices@gradebook.com', to: recipient(invitation.email), subject: "You're Inivited to Join a Course on GradeBook"
  end

  private

  def recipient(email)
    Rails.env == 'staging' ? 'vincedevendra@gmail.com' : email
  end
end
