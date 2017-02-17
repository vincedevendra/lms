require 'spec_helper'

describe Course do
  it { should belong_to(:instructor).class_name('User') }
  it { should have_many(:enrollments) }
  it { should have_many(:students).through(:enrollments) }
  it { should have_many(:assignments) }
  it { should serialize(:meeting_days) }
  it { should validate_presence_of(:title) }

  describe '#students_with_submissions' do
    let(:course){ Fabricate(:course) }
    let(:assignment){ Fabricate(:assignment, course: course) }
    let(:student_1){ Fabricate(:user) }
    let(:student_2){ Fabricate(:user) }
    let!(:submission){ create_submission(student_1, assignment) }
    let!(:non_assinment_submission){ create_submission(student_1) }

    before{ course.students << student_1 << student_2 }

    subject{ course.reload.students_with_submissions(assignment) }

    it 'retrieves all students enrolled in the class' do
      expect(subject).to match_array [student_1, student_2]
    end

    it 'retrieves only submissions for the given assignment' do
      expect(student_1.submissions.count).to eq(2)
      expect(subject.find{ |student| student.id == student_1.id }.submissions).to eq([submission])
    end
  end
end
