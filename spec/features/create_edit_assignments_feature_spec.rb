require 'spec_helper'

feature "instructor creates and edits assignments", js: true do
  let(:instructor) { Fabricate(:instructor)}
  let(:course) { Fabricate(:course, instructor: instructor) }

  background { sign_in_user(instructor) }

  feature "instructor creates an assignment" do
    background do
      visit course_assignments_path(course)
      find("a.new-card").click
    end

    scenario "instructor creates assignment with valid input" do
      expect(page).to have_content("New Assignment")
      fill_in_assignment_fields(valid: true)
      expect(page).to have_content("Essay 1")
    end

    scenario "instructor creates assignment with invalid input" do
      fill_in_assignment_fields(valid: false)
      expect(page).to have_content("errors")
    end

    def fill_in_assignment_fields(valid:)
      fill_in "Title", with: "Essay 1" if valid
      fill_in "Due date", with: "2017-11-20"
      fill_in "Description", with: "Argle Bargle"
      fill_in "Point value", with: "20"
      click_button "Submit"
    end
  end

  feature "instructor edits an assignment" do
    background do
      Fabricate(:assignment, course: course, title: "Essay 1")
      visit course_assignments_path(course)
      click_hamburger
      click_link "Edit"
    end

    scenario "instructor edits course with valid inputs" do
      expect(page).to have_content("Edit Assignment")
      expect(page).to have_selector("input#assignment_title[value='Essay 1']")
      fill_in "Title", with: "Essay 2"
      click_button "Submit"
      expect(page).to have_content("updated")
      expect(page).to have_selector(".assignment-title", text: "Essay 2")
    end

    scenario "instructor edits course with invalid inputs" do
      fill_in "Title", with: ''
      click_button "Submit"
      expect(page).to have_content("errors")
      find('.btn-close').click
      expect(page).to have_content("Essay 1")
    end
  end
end
