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

  def get_grade_for(assignment)
    submissions.find do |submission|
      submission.assignment_id == assignment.id
    end.try(:grade)
  end
end
