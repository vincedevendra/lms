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

    it "renders the create js template" do
      xhr :post, :create, course_id: course.id
      expect(response).to render_template 'create'
    end

    context "when no emails have been inputted" do
      it "sets a flash danger message" do
        expext(flash[:danger]).to be_present
      end
    end

    context "when there are some invalid, registered, unregistered emails" do
      let(:albert) { Fabricate(:user, email: 'albert@al.bert') }
      let(:burt) { Fabricate(:user, email: 'bu@rt.com') }
      let(:unregistered_email) { 'Foo@bar.com' }
      let(:invalid_email) { 'booooop' }

      before do
        xhr :post, :create, course_id: course.id,
            student_emails:
              "#{albert.email},#{burt.email},#{unregistered_email},
               #{invalid_email}"
      end

      after { ActionMailer::Base.deliveries.clear }

      context "when emails are already registered" do
        it "enrolls the students in the course" do
          expect(course.reload.students.count).to eq(2)
        end

        it "flashes a success message" do
          expect(flash[:success]).to be_present
        end
      end

      context "when emails are not already registered" do
        it "sets a flash info message" do
          expect(flash[:info]).to be_present
        end

        context "invitation sending" do
          it "generates a invitation" do
            expect(Invitation.count).to eq(1)
          end

          it "sets the invitation's email attribute to the email" do
            expect(Invitation.first.invitee_email).to eq(unregistered_email)
          end

          it "sets the inivitation's course_id to the course" do
            expect(Invitation.first.course).to eq(course)
          end

          it "sends an email to the unregistered email" do
            expect(ActionMailer::Base.deliveries.)
          end
        end
      end
    end

    context "when emails are not validly formatted" do
      it "flashes a danger message" do
        expect(flash[:danger]).to include("noogie")
        expect(flash[:danger]).not_to include(albert.email)
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
