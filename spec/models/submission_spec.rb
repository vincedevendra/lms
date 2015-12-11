require 'spec_helper'

describe Submission do
  it { should belong_to(:student).class_name('User') }
  it { should belong_to(:assignment) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:assignment_id) }

  describe '#display_submitted_at_time' do
    it 'display formatted time last updated' do
      submission = create_submission
      submission.update_attribute(:submitted_at, '2015-11-10 11:28:15 -0500')
      expect(submission.display_submitted_at_time).to eq('10 Nov 2015 4:28 PM')
    end
  end
  
  describe "#upload_to_box_view" do
    it "uploads the submission to Box View" do
      submission = create_submission
      allow(BoxViewWrapper).to receive(:upload).with(submission)

      submission.upload_to_box_view
      
      expect(BoxViewWrapper).to have_received(:upload).with(submission)
    end
  end
end
