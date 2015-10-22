require 'spec_helper'

feature "hides controls from students" do
  scenario "when student signs in controls are hidden" do
    course = Fabricate(:course, title: "Foo 101")
    assignment = Fabricate(:assignment, title: "Essay", course: course)
    student = Fabricate(:user)
    instructor = Fabricate(:instructor)
    instructor.courses_owned << course
    student.courses << course

    sign_in_user(instructor)
    expect(page).to have_selector('.new-card')
    expect(page).to have_content("Foo 101")
    expect(page).to have_selector('.hamburger')
    find('.hamburger').click
    expect(page).to have_content('Edit')
    expect(page).to have_content('Delete')
    expect(page).to have_content('Enroll Students')
    expect(page).not_to have_content('Disenroll')

    visit course_assignments_path(course)
    expect(page).to have_selector('.new-card')
    expect(page).to have_content('Essay')
    expect(page).to have_selector('.hamburger')
    expect(page).to have_link "Submissions"

    click_link "Sign Out"
    sign_in_user(student)
    expect(page).not_to have_selector('.new-card')
    expect(page).to have_content("Foo 101")
    find('.hamburger').click
    expect(page).not_to have_content('Edit')
    expect(page).not_to have_content('Delete')
    expect(page).not_to have_content('Enroll Students')
    expect(page).to have_content('Disenroll')

    visit course_assignments_path(course)
    expect(page).not_to have_selector('.new-card')
    expect(page).to have_content('Essay')
    expect(page).not_to have_link "Submissions"
  end
end
