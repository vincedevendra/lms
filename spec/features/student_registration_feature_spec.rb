require 'spec_helper'

feature "student registration" do
  scenario "creating a new student account" do
    visit register_path
    fill_in "Email", with: Faker::Internet.email
    fill_in "Password", with: 'password'
    fill_in "Confirm Password", with: 'password'
    fill_in "College ID", with: '123456'
    fill_in "First name", with: 'Vincent'
    fill_in "Last name", with: "D"
    click_button "Submit"

    expect(page).to have_content "Vincent"
  end
end