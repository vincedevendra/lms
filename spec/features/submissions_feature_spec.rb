require 'spec_helper'

feature 'student uploads and updates submission' do
  feature "upload form hidden when assignment doesn't require submission" do
    given(:course) { Fabricate(:course) }
    given(:student) { Fabricate(:user) }
    given(:instructor) { Fabricate(:instructor) }
    given!(:assignment) { Fabricate(:assignment, course: course, submission_required: false) }

    background do
      student.courses << course
      instructor.courses_owned << course
      sign_in_user(student)
      visit course_assignments_path(course)
    end

    scenario 'it hides the submisison form from student' do
      expect(page).to have_content "Choose a New File"
    end
  end

  feature 'student uploads submission' do
    given(:course) { Fabricate(:course) }
    given(:student) { Fabricate(:user) }
    given(:instructor) { Fabricate(:instructor) }
    given!(:assignment) { Fabricate(:assignment, course: course, submission_required: false) }

    background do
      student.courses << course
      instructor.courses_owned << course
      sign_in_user(student)
      visit course_assignments_path(course)
    end

    context 'when the student is enrolled in the class' do
      scenario 'student does not choose a file to upload' do
        expect_msg_and_no_create_when_blank
      end

      scenario 'student chooses a file with a restricted mime type' do
        upload_restricted_mime_type
        expect(page).to have_content("not allowed to upload \"xlsx\" files")
        expect(Submission.where(user_id: student.id, assignment_id: assignment.id).count).to eq(0)
      end

      scenario 'student chooses a file with a whitelisted mime type' do
        attach_file 'submission_submission', "#{Rails.root}/tmp/sample.docx"
        click_button 'Upload'
        expect(page).to have_content('Your file has been uploaded')
        expect(page).to have_content('sample.docx')
        expect(Submission.where(user_id: student.id, assignment_id: assignment.id).count).to eq(1)
      end
    end
  end

  feature 'student changes submission' do
    given(:course) { Fabricate(:course) }
    given(:student) { Fabricate(:user) }
    given(:instructor) { Fabricate(:instructor) }
    given!(:assignment) { Fabricate(:assignment, course: course, submission_required: false) }

    background do
      student.courses << course
      instructor.courses_owned << course
      sign_in_user(student)
      visit course_assignments_path(course)
      upload_valid_file
    end

    scenario 'student does not choose a file to upload' do
      expect(page).to have_content 'sample.docx'
      expect_msg_and_no_create_when_blank
    end

    scenario 'student chooses a file with a restricted mime type' do
      expect(page).to have_content 'sample.docx'
      upload_restricted_mime_type
      expect(page).to have_content("not allowed to upload \"xlsx\" files")
    end

    scenario 'student chooses a file with a whitelisted mime type' do
      expect(page).to have_content 'sample.docx'
      upload_replacement_file
      expect(page).to have_content('Your file has been uploaded')
      expect(page).to have_content('sample_2.docx')
      expect(Submission.where(user_id: student.id, assignment_id: assignment.id).count).to eq(1)
    end
  end

  def upload_valid_file
    attach_file 'submission_submission', "#{Rails.root}/tmp/sample.docx"
    click_button 'Upload'
  end

  def upload_replacement_file
    attach_file 'submission_submission', "#{Rails.root}/tmp/sample_2.docx"
    click_button 'Upload'
  end

  def upload_restricted_mime_type
    attach_file 'submission_submission', "#{Rails.root}/tmp/sample.xlsx"
    click_button 'Upload'
  end

  def expect_msg_and_no_create_when_blank
    count = Submission.count
    click_button 'Upload'
    expect(page).to have_content('Please choose a file')
    expect(Submission.count).to eq(count)
  end
end
