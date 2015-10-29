class User < ActiveRecord::Base
  has_secure_password
  has_many :courses_owned, -> { order(created_at: :desc) }, class_name: "Course", foreign_key: 'instructor_id'
  has_many :enrollments, foreign_key: 'student_id'
  has_many :courses, -> { order(title: :asc) }, through: :enrollments
  has_many :submissions

  validates_presence_of [:email, :password, :password_confirmation, :first_name, :last_name]
  validates_confirmation_of :password
  validates_uniqueness_of :email

  def full_name
    first_name + " " + last_name
  end

  def assignment_submission(assignment)
    submissions.bsearch { |submission| submission.assignment == assignment }
  end

  def display_submission_time(assignment)
    assignment_submission(assignment)
      .try(:updated_at)
      .try(:strftime, '%d %b %Y%l:%M %p')
  end
end
