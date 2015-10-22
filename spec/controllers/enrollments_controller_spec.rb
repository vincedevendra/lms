require 'spec_helper'
include ActiveJob::TestHelper

describe EnrollmentsController do
  describe "GET new" do
    let!(:course) { Fabricate(:course) }
    before { xhr :get, :new, course_id: course.id }

    it "assigns @course from the params" do
      expect(assigns(:course)).to eq(course)
    end

    it "renders with new js template" do
      expect(response).to render_template 'enrollments/new'
    end
  end

  describe "POST create" do
    let(:course) { Fabricate(:course) }
    messages = {info: 'hey', danger: 'ho', success: 'here', warning: 'we go' }
    let(:enroller) { double('enroller', messages: messages) }

    before do
      allow(Enroller).to receive(:new) { enroller }
      allow(enroller).to receive(:run)
    end

    it 'runs the enroller' do
      expect(enroller).to receive(:run)
      xhr :post, :create, course_id: course.id, student_emails: 'foo'
    end

    it "renders the create js template" do
      xhr :post, :create, course_id: course.id
      expect(response).to render_template 'create'
    end

    context "when no email addresses have been inputted" do
      it "sets a flash danger message" do
        xhr :post, :create, course_id: course.id, student_emails: ''
        expect(flash[:danger]).to be_present
      end

      it 'does not run the enroller' do
        expect(enroller).not_to receive(:run)
        xhr :post, :create, course_id: course.id, student_emails: ''
      end
    end

    context "when there are some invalid, registered, unregistered emails" do
      before { xhr :post, :create, course_id: course.id, student_emails: 'foo' }

      it 'sets a flash warning message' do
        expect(flash[:warning]).to be_present
      end

      it 'sets a flash info message' do
        expect(flash[:info]).to be_present
      end

      it 'sets a flash success message' do
        expect(flash[:success]).to be_present
      end

      it 'sets a flash danger message' do
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "DELETE destroy" do
    let(:course) { Fabricate(:course) }
    let(:student) { Fabricate(:user) }

    before do
      set_current_user(student)
      student.courses << course
      delete :destroy, course_id: course.id
    end

    it "disenrolls the student from the course" do
      expect(student.courses).not_to include(course)
    end

    it "redirects to the root path" do
      expect(response).to redirect_to root_path
    end
  end
end
