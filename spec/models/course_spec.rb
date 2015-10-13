require 'spec_helper'

describe Course do
  it { should belong_to(:instructor).class_name('User') }
  it { should have_many(:enrollments) }
  it { should have_many(:students).through(:enrollments) }
  it { should have_many(:assignments) }
  it { should serialize(:meeting_days) }
  it { should validate_presence_of(:title) }
end
