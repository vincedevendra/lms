require 'spec_helper'

describe Enrollment do
  it { should belong_to(:student).class_name('User') }
  it { should belong_to(:course)}
  it { should validate_presence_of(:student_id) }
  it { should validate_presence_of(:course_id) }
end
