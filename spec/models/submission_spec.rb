require 'spec_helper'

describe Submission do
  it { should belong_to(:student).class_name('User') }
  it { should belong_to(:assignment) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:assignment_id) }
end
