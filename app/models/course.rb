class Course < ActiveRecord::Base
  belongs_to :instructor, class_name: 'User'
  has_many :enrollments
  has_many :students, through: :enrollments
  has_many :assignments
  serialize :meeting_days

  validates_presence_of :title
end
