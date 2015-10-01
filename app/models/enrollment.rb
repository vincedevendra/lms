class Enrollment < ActiveRecord::Base
  belongs_to :student, class_name: 'User', foreign_key: 'user_id'
  belongs_to :course

  validates_presence_of [:user_id, :course_id]
end
