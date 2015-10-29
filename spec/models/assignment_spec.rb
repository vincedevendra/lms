require 'spec_helper'

describe Assignment do
  it { should belong_to :course}
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :due_date }
  it { should validate_presence_of :point_value }
  it { should have_many :submissions }
end
