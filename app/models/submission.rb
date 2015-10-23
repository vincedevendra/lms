class Submission < ActiveRecord::Base
  mount_uploader :submission, SubmissionUploader
end
