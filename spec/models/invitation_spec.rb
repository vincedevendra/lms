require 'spec_helper'

describe Invitation do
  it { should belong_to(:course) }
  it { should validate_presence_of :course_id }
  it { should validate_presence_of :email }
end
