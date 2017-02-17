require 'spec_helper'

describe Grade do
  it { should belong_to :assignment }
  it { should belong_to(:student).class_name('User') }
  it { should validate_presence_of :points }
  it { should validate_presence_of :student_id }
  it { should validate_presence_of :assignment_id }
  it { should validate_uniqueness_of(:student_id).scoped_to(:assignment_id) }
end
