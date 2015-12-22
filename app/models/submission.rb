class Submission < ActiveRecord::Base
  mount_uploader :submission, SubmissionUploader

  belongs_to :student, class_name: 'User', foreign_key: 'user_id'
  belongs_to :assignment

  validates_presence_of [:submission, :user_id, :assignment_id]

  def display_submitted_at_time
    submitted_at.strftime('%d %b %Y%l:%M %p')
  end

  def box_view_url
    BoxViewWrapper.view_url(box_view_id) if box_view_id?
  end
end
