class Submission < ActiveRecord::Base
  mount_uploader :submission, SubmissionUploader

  belongs_to :student, class_name: 'User', foreign_key: 'user_id'
  belongs_to :assignment

  validates_presence_of [:submission, :user_id, :assignment_id]
end
