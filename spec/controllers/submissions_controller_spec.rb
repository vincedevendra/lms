require 'spec_helper'

describe SubmissionsController do
  let(:instructor) { Fabricate(:instructor) }
  let(:course) { Fabricate(:course, instructor: instructor) }
  let(:student) { Fabricate(:user) }
  let(:assignment) { Fabricate(:assignment, course: course) }
  let!(:submission) { create_submission(student, assignment) }

  describe 'POST#create' do
    it_behaves_like 'no_current_user_redirect' do
      let(:action) { post :create, course_id: 2, assignment_id: 3 }
    end

    it_behaves_like 'redirects when not enrolled' do
      let(:action) do
        post :create, course_id: course.id, assignment_id: assignment.id
      end
    end
  end

  describe 'PATCH#update' do
    let(:submission) do
      Submission.create(student: student, assignment: assignment,
                        submission: File.open("#{Rails.root}/tmp/sample.docx"))
    end

    it_behaves_like 'no_current_user_redirect' do
      let(:action) do
        post :update, course_id: 2, assignment_id: 3, id: submission.id
      end
    end

    it_behaves_like 'redirects when not enrolled' do
      let(:course) { Fabricate(:course) }
      let(:instructor) { Fabricate(:instructor) }
      let(:action) do
        patch :update, course_id: course.id, assignment_id: assignment.id,
              id: submission.id
      end
    end
  end
end