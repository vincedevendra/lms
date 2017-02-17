class StudentSubmissionTracker
  attr_reader :student, :assignment_submission
  delegate :first_name, :last_name, :student_id, :id, :grade_for, :assignment_grade?, to: :@student
  delegate :display_submitted_at_time, :submission_url, to: :@assignment_submission

  def initialize(student, submission)
    @student = student
    @assignment_submission = submission
  end
end
