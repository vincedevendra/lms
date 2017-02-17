require 'spec_helper'

describe GradeTracker::Course do
  describe '#new' do
    it 'sets course from argument' do
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)

      expect(course_grade_tracker.course).to eq(course)
    end
  end

  describe '#students' do
    it 'returns an empty array if the course has no students' do
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)

      expect(course_grade_tracker.students).to be_empty
    end

    it 'creates student grade trackers for each student' do
      course = Fabricate(:course)
      student_1 = Fabricate(:user)
      student_2 = Fabricate(:user)
      course.students << student_1 << student_2
      course_grade_tracker = GradeTracker::Course.new(course)

      expect(course_grade_tracker.students.count).to eq(2)
      expect(course_grade_tracker.students.first).to be_an_instance_of(GradeTracker::Course::Student)
    end
  end

  describe '#average_grade' do
    it 'returns nil if the course has no students' do
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)

      expect(course_grade_tracker.average_grade).to be_nil
    end

    it 'returns nil if the course has only students without course averages' do
      student_1 = double(course_average: nil)
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)
      allow(course_grade_tracker).to receive(:students){ [student_1] }

      expect(course_grade_tracker.average_grade).to be_nil
    end

    it "returns the average of all the students' average grades" do
      student_1 = double(course_average: 80)
      student_2 = double(course_average: 100)
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)
      allow(course_grade_tracker).to receive(:students) do
        [student_1, student_2]
      end

      expect(course_grade_tracker.average_grade).to eq(90)
    end

    it 'averages only the student grades that are not nil' do
      student_1 = double(course_average: 80)
      student_2 = double(course_average: 100)
      student_3 = double(course_average: nil)
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)
      allow(course_grade_tracker).to receive(:students) do
         [student_1, student_2, student_3]
      end

      expect(course_grade_tracker.average_grade).to eq(90)
    end
  end

  describe '#median_grade' do
    it 'returns nil if the course has no students' do
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)

      expect(course_grade_tracker.median_grade).to be_nil
    end

    it 'returns nil if the course has only students without course averages' do
      student_1 = double(course_average: nil)
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)
      allow(course_grade_tracker).to receive(:students){ [student_1] }

      expect(course_grade_tracker.median_grade).to be_nil
    end

    it 'when all students have course averages it returns the median grade' do
      student_1 = double(course_average: 80)
      student_2 = double(course_average: 100)
      student_3 = double(course_average: 85)
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)
      allow(course_grade_tracker).to receive(:students) do
         [student_1, student_2, student_3]
      end

      expect(course_grade_tracker.median_grade).to eq(85)
    end

    it 'returns the median grade only for students who have course averages' do
      student_1 = double(course_average: 80)
      student_2 = double(course_average: 100)
      student_3 = double(course_average: nil)
      course = Fabricate(:course)
      course_grade_tracker = GradeTracker::Course.new(course)
      allow(course_grade_tracker).to receive(:students) do
         [student_1, student_2, student_3]
      end

      expect(course_grade_tracker.median_grade).to eq(90)
    end
  end

  describe GradeTracker::Course::Student do
    describe '#new' do
      it 'sets @student from args' do
        student = Fabricate(:user)
        course = Fabricate(:course)
        student_course_grade_tracker =
          GradeTracker::Course::Student.new(student, course)

        expect(student_course_grade_tracker.student).to eq(student)
      end

      it 'sets @course from args' do
        student = Fabricate(:user)
        course = Fabricate(:course)
        student_course_grade_tracker =
          GradeTracker::Course::Student.new(student, course)

        expect(student_course_grade_tracker.instance_variable_get('@course')).to eq(course)
      end
    end

    describe '#assignment_grades' do
      it 'returns a hash with assignemnt id keys and student grade values' do
        student = double('student')
        course = Fabricate(:course)
        assignment_1 = Fabricate(:assignment, course: course)
        assignment_2 = Fabricate(:assignment, course: course)
        grade_1 = double('grade_1', points: 10)
        grade_2 = double('grade_1', points: 20)
        allow(student).to receive(:grade_for).with(assignment_1) { grade_1 }
        allow(student).to receive(:grade_for).with(assignment_2) { grade_2 }
        student_course_grade_tracker =
          GradeTracker::Course::Student.new(student, course)

        expect(student_course_grade_tracker.assignment_grades).to eq({assignment_1.id => 10, assignment_2.id => 20})
      end
    end

    describe '#course_average' do
      let(:student){ Fabricate(:user) }
      let(:course){ Fabricate(:course) }
      let(:assignment_1) do
        Fabricate(:assignment, course: course, point_value: 20)
      end
      let(:assignment_2) do
        Fabricate(:assignment, course: course, point_value: 20)
      end

      before{ student.courses << course }

      it 'returns nil if student has no submissions for course assignments' do
        student_grade_tracker = GradeTracker::Course::Student.new(student, course)

        expect(student_grade_tracker.course_average).to be_nil
      end

      it 'returns nil if student has no graded course assignments' do
        student_grade_tracker = GradeTracker::Course::Student.new(student, course)
        submission_for_assignment_1 = create_submission(student, assignment_1)

        expect(student_grade_tracker.course_average).to be_nil
      end

      it 'returns the percent average of all graded course assignments, if any' do
        student_grade_tracker = GradeTracker::Course::Student.new(student, course)
        grade_1 = Fabricate(:grade, assignment: assignment_1, student: student, points: 10)
        grade_2 = Fabricate(:grade, assignment: assignment_2, student: student, points: 20)

        expect(student_grade_tracker.course_average).to eq(75)
      end

      it 'returns the precent average of only graded course assignments' do
        student_grade_tracker = GradeTracker::Course::Student.new(student, course)
        grade_1 = Fabricate(:grade, assignment: assignment_1, student: student, points: 10)

        expect(student_grade_tracker.course_average).to eq(50)
      end
    end
  end
end
