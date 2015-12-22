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
  
  describe 'GET#show' do
    it_behaves_like 'no_current_user_redirect' do
      let(:course) { Fabricate(:course) }
      let(:assignment) { Fabricate(:assignment, course: course) }
      let(:submission) { create_submission }
      let(:action) { get :show, course_id: course.id, assignment_id: assignment.id, id: submission.id }
    end

    it_behaves_like 'unless_instructor_redirect' do
      let(:course) { Fabricate(:course) }
      let(:assignment) { Fabricate(:assignment, course: course) }
      let(:submission) { create_submission }
      let(:action) { get :show, course_id: course.id, assignment_id: assignment.id, id: submission.id }
    end

    it_behaves_like 'unless_instructor_owns_course_redirect' do
      let(:course) { Fabricate(:course) }
      let(:assignment) { Fabricate(:assignment, course: course) }
      let(:submission) { create_submission }
      let(:instructor) { Fabricate(:instructor) }
      let(:action) { get :show, course_id: course.id, assignment_id: assignment.id, id: submission.id }
    end

    it "it uploads the submission to box view if it doesn't have a box view id", vcr: true do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      course.students << student
      submission = create_submission(student, assignment)
      set_current_user(instructor)
      uploader = double('uploader', :upload_to_box_view)
      allow(SubmissionBoxViewUploader).to receive(:new) { uploader }

      get :show, course_id: course.id, assignment_id: assignment.id, id: submission.id
 
      expect(uploader).to have_received(:upload_to_box_view)
    end

    it "saves the box view id from the upload response if upload is successful", vcr: true do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      course.students << student
      submission = create_submission(student, assignment)
      set_current_user(instructor)

      uploader = double('uploader')
      allow(uploader).to receive (:upload_to_box_view)
      allow(uploader).to receive(:success?) { true }
      allow(uploader).to receive(:box_view_id) { '123' }
      allow(SubmissionBoxViewUploader).to receive(:new) { uploader }

      get :show, course_id: course.id, assignment_id: assignment.id, id: submission.id
 
      expect(submission.reload.box_view_id).to eq('123') 
    end

    it "doesn't upload the submission to box view if it has a box view id", vcr: true do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      course.students << student
      submission = create_submission(student, assignment)
      submission.update_attribute(:box_view_id, '123')
      set_current_user(instructor)
      allow(SubmissionBoxViewUploader).to receive(:upload_to_box_view)

      get :show, course_id: course.id, assignment_id: assignment.id, id: submission.id
 
      expect(SubmissionBoxViewUploader).not_to have_received(:upload_to_box_view)
    end

    it 'assigns submission to instance variable', vcr: true do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      course.students << student
      submission = create_submission(student, assignment)
      set_current_user(instructor)

      get :show, course_id: course.id, assignment_id: assignment.id, id: submission.id
      
      expect(assigns(:submission)).to eq(submission)
    end
    
    it 'renders the show template', vcr: true do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course)
      student = Fabricate(:user)
      course.students << student
      submission = create_submission(student, assignment)
      set_current_user(instructor)

      get :show, course_id: course.id, assignment_id: assignment.id, id: submission.id
      
      expect(response).to render_template(:show)
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
