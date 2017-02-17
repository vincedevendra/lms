require 'spec_helper'
include ActiveJob::TestHelper

describe Enroller do
  describe '#new' do
    context "when all emails are separated by punctuation other than commas" do
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course, instructor: instructor) }
      subject(:enroller) { Enroller.new('foo@bar.com bar@foo.com', course) }

      it "treats the input as a single invalid email address" do
        expect(enroller.invalid_emails).to eq(['foo@bar.com bar@foo.com'])
      end
    end

    context "when there are some invalid, registered, unregistered emails" do
      let(:albert) { Fabricate(:user, email: 'albert@al.bert') }
      let(:burt) { Fabricate(:user, email: 'bu@rt.com') }
      let(:unregistered_email) { 'Foo@bar.com' }
      let(:invalid_email) { 'noogie' }
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course, instructor: instructor) }

      before { albert.courses << course }

      subject(:enroller) do
        emails =
          [albert.email,
           burt.email,
           unregistered_email,
           invalid_email].join(',')
        Enroller.new(emails, course)
      end

      it 'sets the invalid emails' do
        expect(enroller.invalid_emails).to match_array([invalid_email])
      end

      it 'sets the enrolled students' do
        expect(enroller.enrolled_students).to match_array([albert])
      end

      it 'sets the unenrolled students' do
        expect(enroller.unenrolled_students).to match_array([burt])
      end

      it 'sets the unregistered_emails' do
        expect(enroller.unregistered_emails).to match_array([unregistered_email])
      end
    end
  end

  describe '#run' do
    context "when all emails are separated by punctuation other than commas" do
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course, instructor: instructor) }
      subject(:enroller) { Enroller.new('foo@bar.com bar@foo.com', course) }

      before { enroller.run }

      it 'sets a danger message' do
        expect(enroller.messages[:danger]).to be_present
      end
    end

    context "when there are some invalid, registered, unregistered emails" do
      let(:albert) { Fabricate(:user, email: 'albert@al.bert') }
      let(:burt) { Fabricate(:user, email: 'bu@rt.com') }
      let(:unregistered_email) { 'Foo@bar.com' }
      let(:invalid_email) { 'noogie' }
      let(:instructor) { Fabricate(:instructor) }
      let(:course) { Fabricate(:course, instructor: instructor) }

      let(:enroller) do
        emails = [albert.email, burt.email, unregistered_email,
                  invalid_email].join(',')
        Enroller.new(emails, course)
      end

      before do
        albert.courses << course
        perform_enqueued_jobs { enroller.run }
      end

      after { ActionMailer::Base.deliveries.clear }

      context 'with unenrolled students' do
        it "enrolls the students in the course" do
          expect(course.reload.students.count).to eq(2)
        end

        it "adds a success message" do
          expect(enroller.messages[:success]).to be_present
        end

        context "notification email sending" do
          subject do
            AppMailer.deliveries.select do |delivery|
              delivery.subject == "Enrollment Notification"
            end
          end

          it "sends an email" do
            expect(subject.count).to eq(1)
          end

          it "sends emails to those already registered for the site" do
            expect(subject.map(&:to)).to match_array([[burt.email]])
          end

          it "sends an email containing a url with an invite token" do
            expect(subject.first.body).to include(course.title.titleize)
          end
        end
      end

      context 'with unregistered_emails' do
        it "sets an info message" do
          expect(enroller.messages[:info]).to be_present
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

      context 'when emails are not validly formatted' do
        it 'flashes a danger message' do
          expect(enroller.messages[:danger]).to include('noogie')
          expect(enroller.messages[:danger]).not_to include(albert.email)
        end
      end
    end
  end
end
