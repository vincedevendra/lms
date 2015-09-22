require 'spec_helper'

feature "creating, deleting, and editing assignments" do

  scenario "instructor creates, deletes, and edits assignments" do
    user = Fabricate(:user, instructor: true)
    sign_in_user(user)
    click_new_assignment_link

    complete_assignment_form_with_title("Foo")
    expect(page).to have_content("Foo")

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
    click_new_assignment_link
    complete_assignment_form_with_title(title)
  end

  def change_assignment_title_to(title)
    click_link "Edit"
    fill_in "Title", with: title
    click_button "Submit"
  end

  def click_new_assignment_link
    find(:xpath, "//a[@href='#{new_assignment_path}']").click
  end
end
