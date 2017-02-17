class Grade < ActiveRecord::Base
  belongs_to :student, class_name: 'User'
  belongs_to :assignment

  validates_presence_of [:points, :assignment_id, :student_id]
  validates_uniqueness_of :student_id, scope: :assignment_id
end
