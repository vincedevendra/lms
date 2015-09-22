require 'spec_helper'

feature "instructor registration" do
  background { ENV["instructor_key"] = '12345' }

  scenario "creating a new profesor account" do
    visit register_instructor_path
    fill_in "Email", with: Faker::Internet.email
    fill_in "Password", with: 'password'
    fill_in "Confirm Password", with: 'password'
    fill_in "College ID", with: '123456'
    fill_in "First name", with: 'Vincent'
    fill_in "Last name", with: "D"
    fill_in "Key", with: '12345'
    click_button "Submit"

    expect(page).to have_content("Prof.")
  end
end
