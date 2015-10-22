require 'spec_helper'
include ActiveJob::TestHelper

feature 'professor enrolls students', js: true do
  given(:prof_abel) { Fabricate(:instructor) }
  given!(:course) { Fabricate(:course, instructor: prof_abel, title: 'Philosophy 101') }

  background do
    sign_in_user(prof_abel)
    click_hamburger
    click_link 'Enroll Students'
  end

  scenario 'professor enrolls already registered student' do
    student = Fabricate(:user, email: 'foo@bar.net')
    submit_student_emails_form

    expect(page).to have_content('already registered')
    click_link 'Sign Out'

    sign_in_user(student)
    expect(page).to have_content(/Philosophy 101/i)
  end

  scenario 'professor enrolls student not yet registered' do
    submit_student_emails_form
    expect(page).to have_content('An invitation to join GradeBook')

    click_link 'Sign Out'
    sleep 0.5
    click_link 'Sign Out'

    open_email('foo@bar.net')
    current_email.click_link 'here'

    expect(page).to have_content('Register')
    expect(page).to have_field('Email', with: 'foo@bar.net')
    fill_in "Password", with: 'password'
    fill_in "Confirm Password", with: 'password'
    fill_in 'Student ID (optional)', with: '123456'
    fill_in "First name", with: 'Vincent'
    fill_in "Last name", with: "D"
    click_button "Submit"

    expect(page).to have_content(/Philosophy 101/i)
  end

  def submit_student_emails_form
    fill_in 'Student emails', with: 'foo@bar.net'

    perform_enqueued_jobs do
      click_button 'Submit'
      sleep 2.0
    end
  end
end
