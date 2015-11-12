class StudentSubmissionTracker
  attr_reader :student, :submission
  delegate :first_name, to: :@student
  delegate :last_name, to: :@student
  delegate :student_id, to: :@student
  delegate :display_submitted_at_time, to: :@submission
  delegate :submission_url, to: :@submission

  def initialize(student, submission)
    @student = student
    @submission = submission
  end
end
