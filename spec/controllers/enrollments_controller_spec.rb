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
    let(:instructor) { Fabricate(:instructor) }
    let(:course) { Fabricate(:course, instructor: instructor) }

    it "renders the create js template" do
      xhr :post, :create, course_id: course.id
      expect(response).to render_template 'create'
    end

    context "when no email addresses have been inputted" do
      it "sets a flash danger message" do
        xhr :post, :create, course_id: course.id, student_emails: ''
        expect(flash[:danger]).to be_present
      end
    end

    context "when all emails are separated by punctuation other than commas" do
      it "treats the input as a single invalid email address, sets flash danger" do
        xhr :post, :create, course_id: course.id,
            student_emails: 'foo@bar.com bar@foo.com'
        expect(flash[:danger]).to include('foo@bar.com bar@foo.com')
      end
    end

    context "when only invalid emails are included" do
      it "sets a flash danger message" do
        xhr :post, :create, course_id: course.id,
            student_emails: 'foo @ bar, hello'
        expect(flash[:danger]).to include('foo @ bar, hello')
      end
    end

    context "when there are some invalid, registered, and unregistered emails" do
      let(:albert) { Fabricate(:user, email: 'albert@al.bert') }
      let(:burt) { Fabricate(:user, email: 'bu@rt.com') }
      let(:unregistered_email) { 'Foo@bar.com' }
      let(:invalid_email) { 'noogie' }

      before do
        perform_enqueued_jobs do
          xhr :post, :create, course_id: course.id,
              student_emails:         "#{albert.email},#{burt.email},#{unregistered_email},
                   #{invalid_email}"
        end
      end

      after { ActionMailer::Base.deliveries.clear }

      context "when emails are already registered for the site" do
        it "enrolls the students in the course" do
          expect(course.reload.students.count).to eq(2)
        end

        it "flashes a success message" do
          expect(flash[:success]).to be_present
        end

        context "notification email sending" do
          subject do
            AppMailer.deliveries.select do |delivery|
              delivery.subject == "Enrollment Notification"
            end
          end

          it "sends an email" do
            expect(subject.count).to eq(2)
          end

          it "sends emails to those already registered for the site" do
            expect(subject.map(&:to)).to match_array([[albert.email], [burt.email]])
          end

          it "sends an email containing a url with an invite token" do
            expect(subject.first.body).to include(course.title.titleize)
          end
        end
      end

      context "when emails are not already registered" do
        it "sets a flash info message" do
          expect(flash[:info]).to be_present
        end

        context "invitation creation" do
          it "generates a invitation" do
            expect(Invitation.count).to eq(1)
          end

          it "sets the invitation's email attribute to the email" do
            expect(Invitation.first.email).to eq(unregistered_email)
          end

          it "sets the inivitation's course_id to the course" do
            expect(Invitation.first.course).to eq(course)
          end

          it "generates a random token and includes it in the invitation" do
            expect(Invitation.first.token.length).to be_present
          end
        end

        context "email sending" do
          subject do
            AppMailer.deliveries.select do |delivery|
              delivery.subject == "You're Inivited to Join a Course on GradeBook"
            end
          end

          it "sends an invitation email" do
            expect(subject.count).to eq(1)
          end

          it "sends an invitation email to valid email not registered" do
            expect(subject.first.to).to eq([unregistered_email])
          end

          it "sends an invitation email with a url containing token" do
            expect(subject.first.body).to include(Invitation.first.token)
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
