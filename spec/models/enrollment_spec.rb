require 'spec_helper'

describe Enrollment do
  it { should belong_to(:student).class_name('User').with_foreign_key(:user_id) }
  it { should belong_to(:course)}
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:course_id) }
end
