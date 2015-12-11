class Submission < ActiveRecord::Base
  mount_uploader :submission, SubmissionUploader

  belongs_to :student, class_name: 'User', foreign_key: 'user_id'
  belongs_to :assignment

  validates_presence_of [:submission, :user_id, :assignment_id]

  def display_submitted_at_time
    submitted_at.strftime('%d %b %Y%l:%M %p')
  end

  def upload_to_box_view
    response = BoxViewWrapper.upload(self)
    return unless response 
    box_view_id = response["id"]
    submission.update_attribute(:box_view_id, box_view_id)
  end
end
