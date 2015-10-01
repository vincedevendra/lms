class Course < ActiveRecord::Base
  belongs_to :instructor, class_name: 'User', foreign_key: :user_id
  has_many :enrollments
  has_many :students, through: :enrollments
  serialize :meeting_days

  validates_presence_of :title
end
