require 'spec_helper'

feature "instructor creates and edits classes", js: true do
  feature "instructor creates a course" do
    let(:instructor) { Fabricate(:instructor)}

    background do
      sign_in_user(instructor)
      visit courses_path
      click_new_course_link
    end

    scenario "instructor creates a course with valid input" do
      fill_in_course_fields(valid: true)
      expect(page).to have_content(/Philosophy Of The Person/i)
    end

    scenario "instructor creates a course with invalid input" do
      fill_in_course_fields(valid: false)
      expect(page).to have_content("errors")
    end

    def click_new_course_link
      find("a.new-card").click
    end

    def fill_in_course_fields(valid:)
      fill_in "Course Title", with: "Philosophy of the Person" if valid
      fill_in "Course Code", with: "PL1070"
      fill_in "Location", with: "Stoke N201"
      check "monday"
      check "wednesday"
      check "friday"
      fill_in "Start time", with: '1:00PM'
      fill_in "End time", with: '1:50PM'
      click_button "Create Course"
    end
  end

  feature "instructor edits an existing course" do
    let(:instructor) { Fabricate(:instructor) }
    let!(:course) { Fabricate(:course, instructor: instructor, title: "Foo 101") }

    background do
      sign_in_user(instructor)
      visit courses_path
      click_hamburger
      click_link "Edit"
    end

    scenario "instructor edits course with valid inputs" do
      expect(page).to have_content("Edit Course")
      fill_in "Course Title", with: "Bar 102"
      click_button "Update Course"
      expect(page).to have_content("updated")
      expect(page).to have_selector(".course_title", text: /Bar 102/i)
    end

    scenario "instructor edits course with invalid inputs" do
      fill_in "Course Title", with: ''
      click_button "Update Course"
      expect(page).to have_content("errors")
      find('.btn-close').click
      expect(page).to have_content(/Foo 101/i)
    end
  end
end
