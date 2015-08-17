require 'spec_helper'

feature "user signs in" do
  given(:user) { Fabricate(:user) }
  given!(:assignment) { Fabricate(:assignment) }

  scenario "user signs in" do
    visit sign_in_path
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_button "Submit"

    expect(page).to have_content(assignment.title)
    expect(page).to have_content("Sign Out")
  end
end
