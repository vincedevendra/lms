require 'spec_helper'

def set_current_user(user=nil)
  user ||= Fabricate(:user)
  session[:user_id] = user.id
end

def set_instructor_user
  user = Fabricate(:user, instructor: true)
  session[:user_id] = user.id
end

def current_user
  User.find(session[:user_id]) if session[:user_id]
end

def clear_current_user
  session[:user_id] = nil
end

def sign_in_user(user=nil)
  user = user || Fabricate(:user)
  visit sign_in_path
  fill_in "Email", with: user.email
  fill_in "Password", with: 'password'
  click_button 'Submit'
end

def click_hamburger
  find(:css, ".hamburger").click
end

def create_submission(student, assignment)
  Submission.create(student: student, assignment: assignment,
                 submission: File.open("#{Rails.root}/tmp/sample.docx"))
end
