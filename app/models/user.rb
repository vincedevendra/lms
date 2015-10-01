class User < ActiveRecord::Base
  has_secure_password
  has_many :courses_owned, -> { order(created_at: :desc) }, class_name: "Course"
  has_many :enrollments
  has_many :courses, through: :enrollments

  validates_presence_of [:email, :password, :password_confirmation, :first_name, :last_name]
  validates_confirmation_of :password

  def full_name
    first_name + " " + last_name
  end
end
