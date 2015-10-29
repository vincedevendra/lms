require 'spec_helper'

feature 'student uploads and updates submission' do
  given(:course) { Fabricate(:course) }
  given!(:assignment) { Fabricate(:assignment, course: course) }
  given(:student) { Fabricate(:user) }
  given(:instructor) { Fabricate(:instructor) }

  background do
    student.courses << course
    instructor.courses_owned << course
    sign_in_user(student)
    visit course_assignments_path(course)
  end

  feature 'student uploads submission' do
    context 'when the student is enrolled in the class' do
      scenario 'student does not choose a file to upload' do
        expect_msg_and_no_create_when_blank
      end

      scenario 'student chooses a file with a restricted mime type' do
        attach_file 'submission_submission', "#{Rails.root}/tmp/sample.xlsx"
        click_button 'Upload'
        expect(page).to have_content("not allowed to upload \"xlsx\" files")
        expect(Submission.count).to eq(0)
      end

      scenario 'student chooses a file with a whitelisted mime type' do
        attach_file 'submission_submission', "#{Rails.root}/tmp/sample.docx"
        click_button 'Upload'
        expect(page).to have_content('Your file has been uploaded')
        expect(page).to have_content('sample.docx')
        expect(assignment.submissions.count).to eq(1)
        expect(Submission.last.student).to eq(student)
        expect(Submission.last.assignment).to eq(assignment)
      end
    end
  end

  feature 'student changes submission' do
    background { upload_valid_file }

    scenario 'student does not choose a file to upload' do
      expect_msg_and_no_create_when_blank
    end
  end

  def upload_valid_file
    attach_file 'submission_submission', "#{Rails.root}/tmp/sample.docx"
    click_button 'Upload'
  end

  def expect_msg_and_no_create_when_blank
    count = Submission.count
    click_button 'Upload'
    expect(page).to have_content('Please choose a file')
    expect(Submission.count).to eq(count)
  end
end
