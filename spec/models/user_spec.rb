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
  it { should have_many(:grades) }

  describe '#grade_for' do
    let(:student){ Fabricate(:user) }
    let(:course){ Fabricate(:course) }
    let(:assignment){ Fabricate(:assignment, course: course) }
    before{ student.courses << course }

    it 'returns nil if there is no grade for the assignment' do
      expect(student.grade_for(assignment)).to be_nil
    end

    it 'returns the grade for the given assignment if there is one' do
      grade = Grade.create(assignment: assignment, student: student, points: 10)

      expect(student.grade_for(assignment)).to eq(grade)
    end
  end

  describe '#assignment_grade?' do
    let(:student){ Fabricate(:user) }
    let(:course){ Fabricate(:course) }
    let(:assignment){ Fabricate(:assignment, course: course) }
    before{ student.courses << course }

    it 'returns false if there is no grade for the assignment' do
      expect(student.assignment_grade?(assignment)).to be_falsy
    end

    it 'returns true if there is a grade for the assignment' do
      grade = Grade.create(assignment: assignment, student: student, points: 10)

      expect(student.assignment_grade?(assignment)).to be_truthy
    end
  end
end
