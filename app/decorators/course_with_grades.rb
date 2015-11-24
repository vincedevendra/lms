class CourseWithGrades < SimpleDelegator
  delegate :average_grade, :median_grade, to: :@course_grade_tracker

  def initialize(course_grade_tracker)
    super(course_grade_tracker.course.decorate)
    @course_grade_tracker = course_grade_tracker
  end

  def students
    @students ||= @course_grade_tracker.students.map do |student| StudentWithCourseGrades.new(student)
    end
  end

  def avg_letter_grade
    GradeHelper.letter_grade(average_grade)
  end

  def median_letter_grade
    GradeHelper.letter_grade(median_grade)
  end

  def display_average_grade
    GradeHelper.display_percentage(average_grade)
  end

  def display_median_grade
    GradeHelper.display_percentage(median_grade)
  end
end
