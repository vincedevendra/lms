class Invitation < ActiveRecord::Base
  belongs_to :course

  validates_uniqueness_of :token
  validates_presence_of [:email, :course_id]
end
