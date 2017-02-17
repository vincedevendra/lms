require 'spec_helper'

describe StudentWithCourseGrades do
  describe '#course_letter_grade' do
    it 'returns nil if student has no course average' do
      student_grade_tracker = double(course_average: nil)
      allow(student_grade_tracker).to receive(:student)
      student_with_grades = StudentWithCourseGrades.new(student_grade_tracker)

      expect(student_with_grades.course_letter_grade).to be_nil
    end

    it 'returns the appropriate letter grade for average grade' do
      student_grade_tracker = double(course_average: 75)
      allow(student_grade_tracker).to receive(:student)
      student_with_grades = StudentWithCourseGrades.new(student_grade_tracker)

      expect(student_with_grades.course_letter_grade).to eq('C')
    end
  end

  describe '#display_course_average' do
    it 'returns nil if student has no course_average' do
      student_grade_tracker = double(course_average: nil)
      allow(student_grade_tracker).to receive(:student)
      student_with_grades = StudentWithCourseGrades.new(student_grade_tracker)

      expect(student_with_grades.display_course_average).to be_nil
    end

    it 'display formatted percentage grade if student has a course average' do
      student_grade_tracker = double(course_average: 75)
      allow(student_grade_tracker).to receive(:student)
      student_with_grades = StudentWithCourseGrades.new(student_grade_tracker)

      expect(student_with_grades.display_course_average).to eq('75.0%')
    end
  end

  describe '#grade_for' do
    it 'returns nil if there is assignment id not in assignment grade hash' do
      assignment = Fabricate(:assignment)
      id = assignment.id + 1
      student_grade_tracker = double(assignment_grades: {id => 2})
      allow(student_grade_tracker).to receive(:student)
      student_with_grades = StudentWithCourseGrades.new(student_grade_tracker)

      expect(student_with_grades.grade_for(assignment)).to eq(nil)
    end

    it 'returns the value of the assignment id if in assignment grade hash' do
      assignment = Fabricate(:assignment)
      student_grade_tracker = double(assignment_grades: {assignment.id => 2})
      allow(student_grade_tracker).to receive(:student)
      student_with_grades = StudentWithCourseGrades.new(student_grade_tracker)

      expect(student_with_grades.grade_for(assignment)).to eq(2)
    end
  end
end
