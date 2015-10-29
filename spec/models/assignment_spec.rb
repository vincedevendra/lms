require 'spec_helper'

describe Assignment do
  it { should belong_to :course}
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :due_date }
  it { should validate_presence_of :point_value }
  it { should have_many :submissions }

  describe '#student_submission(student)' do
    let(:alice) { Fabricate(:user) }
    let(:betty) { Fabricate(:user) }
    let(:assignment) { Fabricate(:assignment) }
    let!(:submission) { create_submission(alice, assignment) }

    context 'without eager-loading' do
      it 'returns nil if no submission belongs to the student' do
        expect(assignment.student_submission(betty)).to be_nil
      end

      it 'returns the submission belonging to the student' do
        expect(assignment.student_submission(alice)).to eq(submission)
      end
    end

    context 'with eager-loading' do
      let(:assignments) { Assignment.includes(:submissions) }

      it 'returns nil if no submission belongs to the student' do
        expect(assignments.first.student_submission(betty)).to be_nil
      end

      it 'returns the submission belonging to the student' do
        expect(assignments.first.student_submission(alice)).to eq(submission)
      end
    end
  end
end
