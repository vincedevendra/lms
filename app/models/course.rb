class Course < ActiveRecord::Base
  belongs_to :instructor, class_name: 'User'
  has_many :enrollments
  has_many :students, through: :enrollments
  has_many :assignments, -> { order(due_date: :desc) }
  has_many :invitations
  serialize :meeting_days

  validates_presence_of :title
  validates_presence_of :instructor
end
