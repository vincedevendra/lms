require 'spec_helper'

describe Submission do
  it { should belong_to(:user) }
  it { should belong_to(:assignment) }
end
