class Assignment < ActiveRecord::Base
  validates_presence_of [:title, :description, :due_date, :point_value]

  belongs_to :course
  has_many :submissions
  has_many :grades

  def student_submission(student)
    submissions.bsearch { |submission| submission.student == student }
  end

  def existing_or_new_submission(student)
    student_submission(student) || Submission.new
  end

  def average_grade
    grades.average(:points)
  end

  def median_grade
    return if self.grades.empty?

    grades = self.grades.map(&:points).compact.sort
    length = grades.length
    return nil if length.zero?

    if length.odd?
      grades[(length / 2)]
    else
      (grades[(length / 2) - 1] + grades[(length / 2)]) / 2.0
    end
  end
end
