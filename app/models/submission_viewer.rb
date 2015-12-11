class SubmissionViewer
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def box_view_status
    @response["status"]
  end

  def view_url
    submission_box_view_id = submission.box_view_id
    return unless submission_box_view_id
    BoxViewWrapper.view_url(submission_box_view_id)
  end
end

