require 'spec_helper'

feature "creating, deleting, and editing assignments" do

  scenario "professor creates, deletes, and edits assignments" do
    user = Fabricate(:user, professor: true)
    sign_in_user(user)
    click_link "+ New Assignment"

    complete_assignment_form_with_title("Foo")
    expect(page).to have_content("Foo")

    click_button "Options"
    click_link "Delete"

    expect(page).not_to have_content("Foo")

    create_assignment_with_title("Bar")
    change_assignment_title_to("Foo")

    expect(page).to have_content("Foo")
  end

  def complete_assignment_form_with_title(title)
    fill_in "Title", with: title
    fill_in "Description", with: Faker::Lorem.paragraph
    fill_in "Due date", with: "2015-08-19"
    fill_in "Point value", with: "20"
    click_button "Submit"
  end

  def create_assignment_with_title(title)
    click_link "+ New Assignment"
    complete_assignment_form_with_title(title)
  end

  def change_assignment_title_to(title)
    click_button "Options"
    click_link "Edit"
    fill_in "Title", with: title
    click_button "Submit"
  end
end
