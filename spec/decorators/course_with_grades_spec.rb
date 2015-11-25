require 'spec_helper'

describe CourseWithGrades do
  describe '#students' do
    it 'wraps course grade tracker students to student with course grade objects' do
      student_grade_tracker_1 = double(student: nil)
      student_grade_tracker_2 = double(student: nil)

      course_grade_tracker = double(students: [student_grade_tracker_1, student_grade_tracker_2])
      allow(course_grade_tracker).to receive(:course) { double(decorate: nil) }

      course_with_grades = CourseWithGrades.new(course_grade_tracker)

      expect(course_with_grades.students.count).to eq(2)
      expect(course_with_grades.students.first).to be_an_instance_of(StudentWithCourseGrades)
    end
  end

  describe '#avg_letter_grade' do
    it 'returns the letter grade for the course average' do
      course_grade_tracker = double(average_grade: 75, course: double(decorate: nil))
      course_with_grades = CourseWithGrades.new(course_grade_tracker)

      expect(course_with_grades.avg_letter_grade).to eq('C')
    end
  end

  describe '#median_letter_grade' do
    it 'returns the letter grade for the course median' do
      course_grade_tracker = double(median_grade: 75, course: double(decorate: nil))
      course_with_grades = CourseWithGrades.new(course_grade_tracker)

      expect(course_with_grades.median_letter_grade).to eq('C')
    end
  end

  describe '#display_average_grade' do
    it 'returns the decorated percentage grade for the course average' do
      course_grade_tracker = double(average_grade: 75, course: double(decorate: nil))
      course_with_grades = CourseWithGrades.new(course_grade_tracker)

      expect(course_with_grades.display_average_grade).to eq('75.0%')
    end
  end

  describe '#display_median_grade' do
    it 'returns the decorated percentage median grade' do
      course_grade_tracker = double(median_grade: 75, course: double(decorate: nil))
      course_with_grades = CourseWithGrades.new(course_grade_tracker)

      expect(course_with_grades.display_median_grade).to eq('75.0%')
    end
  end
end
