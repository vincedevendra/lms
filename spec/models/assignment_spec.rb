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

  describe '#average_grade' do
    it 'returns nil if there are no submissions for the assignment' do
      assignment = Fabricate(:assignment)

      expect(assignment.average_grade).to be_nil
    end

    it 'returns nil if there are no graded assignments' do
      assignment = Fabricate(:assignment)
      submission_1 = create_submission(nil, assignment)

      expect(assignment.average_grade).to be_nil
    end

    it 'returns the average of all grades for assignment when are all graded' do
      assignment = Fabricate(:assignment)
      submission_1 = create_submission(nil, assignment)
      submission_1.update_attribute(:grade, 8)
      submission_2 = create_submission(nil, assignment)
      submission_2.update_attribute(:grade, 10)

      expect(assignment.average_grade).to eq(9)
    end

    it 'returns the average of only the graded assignments' do
      assignment = Fabricate(:assignment)
      submission_1 = create_submission(nil, assignment)
      submission_1.update_attribute(:grade, 8)
      submission_2 = create_submission(nil, assignment)
      submission_2.update_attribute(:grade, 10)
      submission_3 = create_submission(nil, assignment)

      expect(assignment.average_grade).to eq(9)
    end
  end

  describe '#median_grade' do
    it 'returns nil if there are no submissions for the assignment' do
      assignment = Fabricate(:assignment)
      expect(assignment.median_grade).to be_nil
    end

    it 'returns nil if there are no graded submissions' do
      assignment = Fabricate(:assignment)
      submission = create_submission(nil, assignment)

      expect(assignment.median_grade).to be_nil
    end

    it 'returns the median grade when all submissions are graded' do
      assignment = Fabricate(:assignment)
      submission_1 = create_submission(nil, assignment)
      submission_2 = create_submission(nil, assignment)
      submission_3 = create_submission(nil, assignment)
      submission_1.update_attribute(:grade, 1)
      submission_2.update_attribute(:grade, 2)
      submission_3.update_attribute(:grade, 3)

      expect(assignment.median_grade).to eq(2)
    end

    it 'returns the median for only graded assignments' do
      assignment = Fabricate(:assignment)
      submission_1 = create_submission(nil, assignment)
      submission_2 = create_submission(nil, assignment)
      submission_3 = create_submission(nil, assignment)
      submission_1.update_attribute(:grade, 1)
      submission_2.update_attribute(:grade, 2)
      submission_3.update_attribute(:grade, 3)
      submission_4 = create_submission(nil, assignment)

      expect(assignment.median_grade).to eq(2)
    end

    it 'returns the median for an even number of graded assignments' do
      assignment = Fabricate(:assignment)
      submission_1 = create_submission(nil, assignment)
      submission_2 = create_submission(nil, assignment)
      submission_3 = create_submission(nil, assignment)
      submission_1.update_attribute(:grade, 1)
      submission_2.update_attribute(:grade, 2)

      expect(assignment.median_grade).to eq(1.5)
    end
  end
end
