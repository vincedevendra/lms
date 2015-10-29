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

  describe '#assignment_submission(assignment)' do
    let(:student) { Fabricate(:user) }
    let(:course) { Fabricate(:course) }
    let(:assignment) { Fabricate(:assignment, course: course) }
    subject { student.assignment_submission(assignment) }

    it 'returns nil if there is no submission associated with the assignment' do
      expect(subject).to be_nil
    end

    it 'returns the submission if one is associated with the assignment' do
      submission = create_submission(student, assignment)
      expect(subject).to eq(submission)
    end
  end

  describe '#display_submission_time' do
    let(:student) { Fabricate(:user) }
    let(:course) { Fabricate(:course) }
    let(:assignment) { Fabricate(:assignment, course: course) }
    subject { student.display_submission_time(assignment) }

    it 'returns nil if there is no submission for the assignment' do
      expect(subject).to be_nil
    end

    it 'returns a formatted time for submission updated at if sub exists' do
      submission = create_submission(student, assignment)
      submission_date = DateTime.new(2015, 12, 12, 15, 30)
      submission.update_attribute(:updated_at, submission_date)
      expect(subject).to eq('12 Dec 2015 3:30 PM')
    end
  end
end
