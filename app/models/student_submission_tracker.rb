class StudentSubmissionTracker
  attr_reader :student, :submission
  delegate :first_name, :last_name, :student_id, to: :@student
  delegate :display_submitted_at_time, :submission_url, to: :@submission

  def initialize(student, submission)
    @student = student
    @submission = submission
  end
end
