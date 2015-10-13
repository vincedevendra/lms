class Enrollment < ActiveRecord::Base
  belongs_to :student, class_name: 'User'
  belongs_to :course

  validates_presence_of [:student_id, :course_id]
end
