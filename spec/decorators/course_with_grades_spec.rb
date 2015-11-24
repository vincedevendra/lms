require 'spec_helper'

describe CourseWithGrades do
  describe '#students' do
    it 'wraps course grade tracker students to student with course grade objects' do
      course_grade_tracker = double()
      allow(course_grade_tracker).to receive(:course)
    end
  end
end
