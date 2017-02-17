module GradeTracker
  class Course
    attr_reader :students, :course

    def initialize(course)
      @course = course
    end

    def students
      @students ||= course.students.map do |student|
        GradeTracker::Course::Student.new(student, course)
      end
    end

    def average_grade
      @average_grade ||= begin
        return if students.empty?
        sum_of_averages = student_averages.inject(:+)
        student_count = student_averages.count
        student_count == 0 ? nil : sum_of_averages / student_count
      end
    end

    def median_grade
      @median_grade ||= begin
        return if students.empty?
        averages = student_averages.sort
        return nil if averages.length.zero?
        GradeHelper.calculate_median(averages)
      end
    end

    private

    def student_averages
      students.map(&:course_average).compact
    end

    class Student
      attr_reader :student

      def initialize(student, course)
        @student = student
        @course = course
      end

      def assignment_grades
        @assignment_grades ||= {}

        @course.assignments.each do |assignment|
          @assignment_grades[assignment.id] = @student.grade_for(assignment).try(:points)
        end

        @assignment_grades
      end

      def course_average
        @course_average ||= begin
          possible_points = graded_assignments.map(&:point_value).inject(:+)
          actual_points = @assignment_grades.values.compact.inject(:+)
          actual_points.nil? ? nil : actual_points.to_f / possible_points * 100
        end
      end

      private

      def graded_assignments
        assignment_grades.reject { |_, v| v.nil? }.keys.map do |assignment_id|
          @course.assignments.find do |assignment|
            assignment_id == assignment.id
          end
        end
      end
    end
  end
end
