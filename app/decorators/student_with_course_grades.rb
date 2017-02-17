class StudentWithCourseGrades < SimpleDelegator
  attr_reader :student_grade_tracker
  delegate :course_average, :assignment_grades, to: :student_grade_tracker

  def initialize(student_grade_tracker)
    super(student_grade_tracker.student)
    @student_grade_tracker = student_grade_tracker
  end

  def course_letter_grade
    GradeHelper.letter_grade(course_average)
  end

  def display_course_average
    GradeHelper.display_percentage(course_average)
  end

  def grade_for(assignment)
    assignment_grades[assignment.id]
  end
end
