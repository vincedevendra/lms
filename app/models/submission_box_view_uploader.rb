class SubmissionBoxViewUploader
  attr_reader :submission, :api_response

  def initialize(submission)
    @submission = submission
  end

  def upload_to_box_view
    submission_url = submission.submission_url
    file_name = submission.submission.file.filename

    @api_response = BoxViewWrapper.upload(submission_url, file_name) 
  end

  def success?
    api_response != :error
  end

  def box_view_id
    api_response['id']
  end
end
