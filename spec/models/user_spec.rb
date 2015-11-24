require 'spec_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:password_confirmation) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should have_secure_password }
  it { should validate_confirmation_of(:password) }
  it { should validate_uniqueness_of(:email) }

  it { should have_many(:courses_owned).class_name('Course') }
  it { should have_many(:enrollments) }
  it { should have_many(:courses).through(:enrollments) }
  it { should have_many(:submissions) }

  describe '#get_grade_for' do
    let(:student){ Fabricate(:user) }
    let(:course){ Fabricate(:course) }
    let(:assignment){ Fabricate(:assignment, course: course) }
    before{ student.courses << course }

    it 'returns nil if there is no submission for the assignment' do
      expect(student.get_grade_for(assignment)).to be_nil
    end

    it 'returns nil if is there is a submission but it is ungraded' do
      submission = create_submission(student, assignment)
      expect(student.get_grade_for(assignment)).to be_nil
    end

    it 'returns the grade for the given assignment if there is one' do
      submission = create_submission(student, assignment)
      submission.update_attribute(:grade, 10)

      expect(student.get_grade_for(assignment)).to eq(10)
    end
  end
end
