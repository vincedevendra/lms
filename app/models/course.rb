class Course < ActiveRecord::Base
  belongs_to :instructor, class_name: 'User'
  has_many :enrollments
  has_many :students, through: :enrollments
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
      .order(:last_name)
  end
end
