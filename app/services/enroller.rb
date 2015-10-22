class Enroller
  attr_reader :valid_emails, :invalid_emails, :enrolled_students, :unenrolled_students, :unregistered_emails, :course
  attr_accessor :messages

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  def initialize(student_emails, course)
    @course = course
    @messages = {}
    parse_emails(student_emails, course)
  end

  def run
    set_invalid_emails_message
    set_already_enrolled_students_message
    enroll_unenrolled_students
    invite_unregistered_emails
  end

  private

  def parse_emails(student_emails, course)
    student_emails = student_emails.split(',').map(&:strip).uniq
    valid_emails = student_emails.select { |email| email =~ VALID_EMAIL_REGEX }
    @invalid_emails = student_emails - valid_emails
    registered_students = User.includes(:courses).where(email: valid_emails)
    @enrolled_students = registered_students.select do |student|
      student.courses.include?(@course)
    end
    @unenrolled_students = registered_students - enrolled_students
    @unregistered_emails = valid_emails - registered_students.map(&:email)
  end

  def enroll_unenrolled_students
    if unenrolled_students.any?
      unenrolled_students.each do |student|
        Enrollment.create(course: @course, student: student)
        AppMailer.enrollment_notification(student, @course).deliver_later
      end
      add_unenrolled_students_message
    end
  end

  def invite_unregistered_emails
    if unregistered_emails.any?
      unregistered_emails.each do |email|
        invitation = create_invitation(email)
        AppMailer.invite_to_join_and_enroll(invitation).deliver_later
      end

      add_invitations_sent_message
    end
  end

  def create_invitation(email)
    begin
      token = SecureRandom.urlsafe_base64
    end until !Invitation.find_by(token: token)

    Invitation.create(email: email, course: course, token: token)
  end

  def add_unenrolled_students_message
    names = unenrolled_students.map do |student|
      "#{student.first_name} #{student.last_name}"
    end

    formatted_names = names.join(", ")

    self.messages[:success] = "The following students were already registered for GradeBook and have been successfully enrolled in your course:</br> #{formatted_names}".html_safe
  end

  def set_already_enrolled_students_message
    if enrolled_students.any?
      formatted_emails = enrolled_students.map(&:email).join(', ')
      self.messages[:warning] = "The following students are already enrolled in your course:<br/> #{formatted_emails}".html_safe
    end
  end

  def set_invalid_emails_message
    if invalid_emails.any?
      formatted_emails = invalid_emails.join(", ")
      self.messages[:danger] = "The following emails were not validly formatted:<br/> #{formatted_emails}".html_safe
    end
  end

  def add_invitations_sent_message
    self.messages[:info] = "An invitation to join GradeBook has been sent to the following email addresses.  They will be enrolled in your course at registration:</br>#{unregistered_emails.join(", ")}".html_safe
  end
end
