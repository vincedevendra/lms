require 'spec_helper'

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
    let(:instructor) { Fabricate(:instructor) }

    context "when all emails are validly formatted" do
      after { ActionMailer::Base.deliveries.clear }

      context "when all emails are already registered" do
        let(:albert) { Fabricate(:user, email: 'albert@al.bert') }
        let(:burt) { Fabricate(:user, email: 'bu@rt.com') }

        before do
          xhr :post, :create, course_id: course.id, student_emails: "#{albert.email}, #{burt.email}"
        end

        it "enrolls the students in the course" do
          expect(course.reload.students.count).to eq(2)
        end

        it "sends a notification email to the student" do
          expect(ActionMailer::Base.deliveries.count).to eq(2)
        end

        it "flashes a success message" do
          expect(flash[:success]).to be_present
        end
      end

      context "when some emails are not already registered" do
        let(:unregistered_email) { "Foo@bar.com" }
        let(:albert) { Fabricate(:user, email: 'albert@al.bert') }

        before do
           xhr :post, :create, course_id: course.id, student_emails: unregistered_email + ',' + albert.email
        end

        it "sets a flash info message" do
          expect(flash[:info]).to be_present
        end

        it "generates a invitation" do
          expect(Invitation.count).to eq(1)
        end

        it "sends an email" do
          binding.pry
        end
      end
    end

    context "when some emails are not validly formatted" do
      let(:albert) { Fabricate(:user, email: 'albert@al.bert') }

      before { xhr :post, :create, course_id: course.id, student_emails: "#{albert.email}, noogie"}

      it "flashes a danger message" do
        expect(flash[:danger]).to include("noogie")
        expect(flash[:danger]).not_to include(albert.email)
      end
    end

    it "renders create template" do
      xhr :post, :create, course_id: course.id
      expect(response).to render_template 'enrollments/create'
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
