require 'spec_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:password_confirmation) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should have_secure_password }
  it { should validate_confirmation_of(:password) }
  it { should validate_uniqueness_of(:email) }

  it { should have_many(:courses_owned).class_name('Course') }
  it { should have_many(:enrollments) }
  it { should have_many(:courses).through(:enrollments) }
  it { should have_many(:submissions) }
end
