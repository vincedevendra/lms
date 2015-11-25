require 'spec_helper'

feature 'instructor creates and updates assignment grades', js: true do
  context 'assignment requires submissions' do
    scenario 'instructor grades an assignment' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course, submission_required: true)
      student = Fabricate(:user, first_name: 'Pete')

      course.students << student
      sign_in_user(instructor)
      visit course_assignment_grades_path(course, assignment)

      expect(page).to have_content('Pete')
      fill_in :grade_points, with: '7'
      click_button 'Submit'
      expect(page).to have_content('7.0')
    end

    scenario 'instructor updates an assignment grade' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course, submission_required: true)
      student = Fabricate(:user, first_name: 'Pete')
      grade = Fabricate(:grade, student: student, assignment: assignment, points: 6.0)

      course.students << student
      sign_in_user(instructor)
      visit course_assignment_grades_path(course, assignment)

      expect(page).to have_content('Pete')
      click_link '6.0'
      fill_in :grade_points, with: '7'
      click_button 'Submit'
      expect(page).to have_content('7.0')
    end
  end

  context 'assignment does not require submission' do
    scenario 'instructor grades an assignment' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course, submission_required: false)
      student = Fabricate(:user, first_name: 'Pete')

      course.students << student
      sign_in_user(instructor)
      visit course_assignment_grades_path(course, assignment)

      expect(page).to have_content('Pete')
      fill_in :grade_points, with: '7'
      click_button 'Submit'
      expect(page).to have_content('7.0')
    end

    scenario 'instructor updates an assignment grade' do
      instructor = Fabricate(:instructor)
      course = Fabricate(:course, instructor: instructor)
      assignment = Fabricate(:assignment, course: course, submission_required: false)
      student = Fabricate(:user, first_name: 'Pete')
      grade = Fabricate(:grade, student: student, assignment: assignment, points: 6.0)

      course.students << student
      sign_in_user(instructor)
      visit course_assignment_grades_path(course, assignment)

      expect(page).to have_content('Pete')
      click_link '6.0'
      fill_in :grade_points, with: '7'
      click_button 'Submit'
      expect(page).to have_content('7.0')
    end
  end
end
