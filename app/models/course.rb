class Course < ActiveRecord::Base
  belongs_to :instructor, class_name: 'User'
  has_many :enrollments
  has_many :students, through: :enrollments, -> { order(:last_name) }
  has_many :assignments, -> { order(due_date: :desc) }
  has_many :invitations
  serialize :meeting_days

  validates_presence_of :title
  validates_presence_of :instructor

  def student_submission_trackers(assignment)
    students_with_submissions(assignment).map do |student|
      StudentSubmissionTracker.new(student, student.submissions.first)
    end
  end

  def students_with_submissions(assignment)
    students
      .includes(:submissions)
      .where("submissions.id IS NULL OR submissions.assignment_id = ?",
             assignment.id)
      .references(:submissions)
  end

  def average_grade
    students
      .map{ |student| student.course_average(self) }
      .inject(:+)
  end
end
