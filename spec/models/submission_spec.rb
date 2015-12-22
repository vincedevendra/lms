require 'spec_helper'

describe Submission do
  it { should belong_to(:student).class_name('User') }
  it { should belong_to(:assignment) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:assignment_id) }

  describe '#display_submitted_at_time' do
    it 'should display formatted time last updated' do
      submission = create_submission
      submission.update_attribute(:submitted_at, '2015-11-10 11:28:15 -0500')
      expect(submission.display_submitted_at_time).to eq('10 Nov 2015 4:28 PM')
    end
  end

  describe 'box_view_url' do
    it "calls BoxViewWrapper#view_url if the submission has a box_view_id" do
      submission = Submission.new(box_view_id: '123')
      allow(BoxViewWrapper).to receive(:view_url)              
      
      submission.box_view_url
      
      expect(BoxViewWrapper).to have_received(:view_url).with(submission.box_view_id)
    end

    it "does call BoxViewWrapper#view_url if the submission has no box_view_id" do
      submission = Submission.new
      allow(BoxViewWrapper).to receive(:view_url)              
      
      submission.box_view_url

      expect(BoxViewWrapper).not_to have_received(:view_url)
    end
    
    it "does call BoxViewWrapper#view_url if the submission has no box_view_id" do
      submission = Submission.new
      
      expect(submission.box_view_url).to be_nil
    end
  end
end
