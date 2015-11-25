require 'spec_helper'

describe GradesController do
  describe 'GET#index' do
    it_behaves_like 'no_current_user_redirect' do
      let(:course) { Fabricate(:course) }
      let(:assignment) { Fabricate(:assignment, course: course) }
      let(:action) do
        get :index, course_id: course.id, assignment_id: assignment.id
      end
    end

    it_behaves_like 'unless_instructor_redirect' do
      let(:course) { Fabricate(:course) }
      let(:assignment) { Fabricate(:assignment, course: course) }
      let(:action) do
        get :index, course_id: course.id, assignment_id: assignment.id
      end
    end

    it_behaves_like 'unless_instructor_owns_course_redirect' do
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course) }
      let(:assignment) { Fabricate(:assignment, course: course) }

      let(:action) do
        get :index, course_id: course.id, assignment_id: assignment.id
      end
    end

    it 'sets @course from the params' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      student = Fabricate(:user)
      assignment = Fabricate(:assignment, course: course)
      course.students << student
      set_current_user(instructor)

      get :index, course_id: course.id, assignment_id: assignment.id
      expect(assigns(:course)).to eq(course.decorate)
    end

    it 'sets @assignment from the params' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      student = Fabricate(:user)
      assignment = Fabricate(:assignment, course: course)
      course.students << student
      set_current_user(instructor)

      get :index, course_id: course.id, assignment_id: assignment.id
      expect(assigns(:assignment)).to eq(assignment)
    end

    it "sets @students to students with associated submissions if submissions are required for assignment" do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      student = Fabricate(:user)
      assignment = Fabricate(:assignment, course: course, submission_required: true)
      submission = create_submission(student, assignment)
      course.students << student
      set_current_user(instructor)

      get :index, course_id: course.id, assignment_id: assignment.id

      student_with_sub = StudentSubmissionTracker.new(student, submission)
      expect(assigns(:students).first.student).to eq(student_with_sub.student)
      expect(assigns(:students).first.assignment_submission).to eq(submission)
    end

    it "sets @students to assignment course's enrolled students when submissions are not required" do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      student = Fabricate(:user)
      assignment = Fabricate(:assignment, course: course, submission_required: false)
      course.students << student
      set_current_user(instructor)

      get :index, course_id: course.id, assignment_id: assignment.id

      expect(assigns(:students)).to eq([student])
    end

    it 'renders the index template' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      student = Fabricate(:user)
      assignment = Fabricate(:assignment, course: course)
      course.students << student
      set_current_user(instructor)

      get :index, course_id: course.id, assignment_id: assignment.id

      expect(response).to render_template :index
    end
  end

  describe '#create' do
    it_behaves_like 'no_current_user_redirect' do
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course, instructor: instructor) }
      let(:assignment) { Fabricate(:assignment) }
      let(:action) do
         xhr :post, :create, course_id: course.id, assignment_id: assignment.id, grade: { points: 8 }
      end
    end

    it_behaves_like 'unless_instructor_redirect' do
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course, instructor: instructor) }
      let(:assignment) { Fabricate(:assignment) }
      let(:action) do
         xhr :post, :create, course_id: course.id, assignment_id: assignment.id,  grade: { points: 7 }
      end
    end

    it_behaves_like 'unless_instructor_owns_course_redirect' do
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course) }
      let(:assignment) { Fabricate(:assignment) }
      let(:action) do
         xhr :post, :create, course_id: course.id, assignment_id: assignment.id,  grade: { points: 7 }
      end
    end

    context "when the student isn't enrolled in the course" do
      it 'redirects to the grades#index' do
        instructor = Fabricate(:instructor)
        course = Fabricate(:course, instructor: instructor)
        assignment = Fabricate(:assignment, course: course)
        student = Fabricate(:user)
        set_current_user(instructor)

        xhr :post, :create, course_id: course.id, assignment_id: assignment.id,  grade: { student_id: student.id, points: 7 }

        expect(response).to redirect_to(course_assignment_grades_path)
      end

      it "doesn't create the grade" do
        instructor = Fabricate(:instructor)
        course = Fabricate(:course, instructor: instructor)
        assignment = Fabricate(:assignment, course: course)
        student = Fabricate(:user)
        set_current_user(instructor)

        xhr :post, :create, course_id: course.id, assignment_id: assignment.id,  grade: { student_id: student.id, points: 7 }

        expect(Grade.count).to eq(0)
      end

      it 'flashes an danger message' do
        instructor = Fabricate(:instructor)
        course = Fabricate(:course, instructor: instructor)
        assignment = Fabricate(:assignment, course: course)
        student = Fabricate(:user)
        set_current_user(instructor)

        xhr :post, :create, course_id: course.id, assignment_id: assignment.id,  grade: { student_id: student.id, points: 7 }
        expect(flash[:danger]).to be_present
      end
    end

    it 'updates the student grade with the inputted grade when valid' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      student.courses << course
      set_current_user(instructor)

      xhr :post, :create, course_id: course.id, assignment_id: assignment.id,  grade: { student_id: student.id, points: 7 }

      expect(Grade.first.points).to eq(7.0)
    end

    it 'updates the submission with 0 when input is invalid' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      student.courses << course
      set_current_user(instructor)

      xhr :post, :create, course_id: course.id, assignment_id: assignment.id,  grade: { student_id: student.id, points: 'kazoo' }

      expect(Grade.first.points).to eq(0.0)
    end

    it 'renders the create template' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      student.courses << course
      set_current_user(instructor)

      xhr :post, :create, course_id: course.id, assignment_id: assignment.id,  grade: { student_id: student.id, points: 7 }

      expect(response).to render_template('create')
    end
  end

  describe '#update' do
    it_behaves_like 'no_current_user_redirect' do
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course, instructor: instructor) }
      let(:assignment) { Fabricate(:assignment) }
      let(:student) { Fabricate(:user) }
      let(:grade) { Fabricate(:grade, assignment: assignment, student: student, points: 10)}
      let(:action) do
         xhr :patch, :update, course_id: course.id, assignment_id: assignment.id, grade: { points: 8 }, id: grade.id
      end
    end

    it_behaves_like 'unless_instructor_redirect' do
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course, instructor: instructor) }
      let(:assignment) { Fabricate(:assignment) }
      let(:student) { Fabricate(:user) }
      let(:grade) { Fabricate(:grade, assignment: assignment, student: student, points: 10)}
      let(:action) do
         xhr :patch, :update, course_id: course.id, assignment_id: assignment.id, grade: { points: 8 }, id: grade.id
      end
    end

    it_behaves_like 'unless_instructor_owns_course_redirect' do
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course, instructor: instructor) }
      let(:assignment) { Fabricate(:assignment) }
      let(:student) { Fabricate(:user) }
      let(:grade) { Fabricate(:grade, assignment: assignment, student: student, points: 10)}
      let(:action) do
         xhr :patch, :update, course_id: course.id, assignment_id: assignment.id, grade: { points: 8 }, id: grade.id
      end
    end

    it 'updates the student grade with the inputted grade when valid' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      grade = Fabricate(:grade, assignment: assignment, student: student, points: 10.0)
      student.courses << course
      set_current_user(instructor)

      xhr :patch, :update, course_id: course.id, assignment_id: assignment.id, grade: { points: 8 }, id: grade.id

      expect(Grade.first.points).to eq(8.0)
    end

    it 'updates the submission with 0 when input is invalid' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      grade = Fabricate(:grade, assignment: assignment, student: student, points: 10.0)
      student.courses << course
      set_current_user(instructor)

      xhr :patch, :update, course_id: course.id, assignment_id: assignment.id, grade: { points: 'kazoo' }, id: grade.id

      expect(Grade.first.points).to eq(0.0)
    end

    it 'renders the create template' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      grade = Fabricate(:grade, assignment: assignment, student: student, points: 10.0)
      student.courses << course
      set_current_user(instructor)

      xhr :patch, :update, course_id: course.id, assignment_id: assignment.id, grade: { points: 8 }, id: grade.id

      expect(response).to render_template('create')
    end
  end
end
