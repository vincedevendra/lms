require 'spec_helper'

describe GradesController do
  let(:instructor) { Fabricate(:instructor) }
  let(:course) { Fabricate(:course, instructor: instructor) }
  let(:student) { Fabricate(:user) }
  let(:assignment) { Fabricate(:assignment, course: course) }
  let!(:submission) { create_submission(student, assignment) }

  describe 'GET#index' do
    before do
      course.students << student
      set_current_user(instructor)
    end

    it_behaves_like 'no_current_user_redirect' do
      let(:action) do
        get :index, course_id: course.id, id: assignment.id
      end
    end

    it_behaves_like 'unless_instructor_redirect' do
      let(:action) do
        get :index, course_id: course.id, id: assignment.id
      end
    end

    it_behaves_like 'unless_instructor_owns_course_redirect' do
      let(:instructor) { Fabricate(:instructor) }
      let(:course_2) { Fabricate(:course) }
      let(:action) do
        get :index, course_id: course_2.id, id: assignment.id
      end
    end

    it 'sets @course from the params' do
      get :index, course_id: course.id, id: assignment.id
      expect(assigns(:course)).to eq(course.decorate)
    end

    it 'sets @assignment from the params' do
      get :index, course_id: course.id, id: assignment.id
      expect(assigns(:assignment)).to eq(assignment)
    end

    it "sets @student_submissions to students with associated submissions" do
      get :index, course_id: course.id, id: assignment.id
      student_submission = StudentSubmissionTracker.new(student, submission)
      expect(assigns(:student_submissions).first.student).to eq(student)
      expect(assigns(:student_submissions).first.submission).to eq(submission)
    end

    it 'renders the index template' do
      get :index, course_id: course.id, id: assignment.id

      expect(response).to render_template :index
    end
  end

  describe '#create' do
    let(:student) { Fabricate(:user) }
    let(:instructor) { Fabricate(:instructor) }
    let(:course) { Fabricate(:course, instructor: instructor) }
    let(:assignment) { Fabricate(:assignment, course: course) }
    let!(:submission) { create_submission(student, assignment) }

    before { set_current_user(instructor) }

    it_behaves_like 'no_current_user_redirect' do
      let(:action) do
         xhr :post, :create, course_id: course.id, id: assignment.id, submission: submission.id
      end
    end

    it_behaves_like 'unless_instructor_redirect' do
      let(:action) do
         xhr :post, :create, course_id: course.id, id: assignment.id, submission: submission.id
      end
    end

    it_behaves_like 'unless_instructor_owns_course_redirect' do
      let(:course_2) { Fabricate(:course) }
      let(:action) do
         xhr :post, :create, course_id: course_2.id, id: assignment.id, submission: submission.id
      end
    end

    it 'sets @submission from the params' do
      xhr :post, :create, course_id: course.id, id: assignment.id, submission: submission.id
      expect(assigns(:submission)).to eq(submission)
    end

    context 'when the assignment is not yet graded' do
      it 'updates the submission with the inputted grade when valid' do
        xhr :post, :create, course_id: course.id, id: assignment.id, submission: submission.id, grade: 7
        expect(submission.reload.grade).to eq(7)
      end

      it 'updates the submission with 0 when input is invalid' do
        xhr :post, :create, course_id: course.id, id: assignment.id, submission: submission.id, grade: 'kazoo'
        expect(submission.reload.grade).to eq(0)
      end

      it 'renders the create template' do
        xhr :post, :create, course_id: course.id, id: assignment.id, submission: submission.id, grade: 7
        expect(response).to render_template('create')
      end
    end

    context 'when the assignment is already graded' do
      before{ submission.update_attribute(:grade, 2) }

      it 'updates the submission with the inputted grade when valid' do
        xhr :post, :create, course_id: course.id, id: assignment.id, submission: submission.id, grade: 7
        expect(submission.reload.grade).to eq(7)
      end

      it 'updates the submission with 0 when input is invalid' do
        xhr :post, :create, course_id: course.id, id: assignment.id, submission: submission.id, grade: 'kazoo'
        expect(submission.reload.grade).to eq(0)
      end

      it 'renders the create template' do
        xhr :post, :create, course_id: course.id, id: assignment.id, submission: submission.id, grade: 7
        expect(response).to render_template('create')
      end
    end
  end
end
