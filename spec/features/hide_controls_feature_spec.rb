require 'spec_helper'

feature "hides assignment controls from students" do
  scenario "when student signs in controls are hidden" do
    assignment = Fabricate(:assignment, title: "Foo")
    sign_in_user

    expect(page).not_to have_content("+ New Assignment")
    expect(page).to have_content("Foo")
    expect(page).not_to have_content("Options")
  end
end
