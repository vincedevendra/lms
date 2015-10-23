class Assignment < ActiveRecord::Base
  validates_presence_of [:title, :description, :due_date, :point_value]

  belongs_to :course
  has_many :submissions
end
