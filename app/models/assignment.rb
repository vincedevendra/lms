class Assignment < ActiveRecord::Base
  validates_presence_of [:title, :description, :due_date, :point_value]

  belongs_to :course
  has_many :submissions

  def student_submission(student)
    submissions.bsearch { |submission| submission.student == student }
  end

  def existing_or_new_submission(student)
    student_submission(student) || Submission.new
  end
end
