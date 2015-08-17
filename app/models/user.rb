class User < ActiveRecord::Base
  has_secure_password

  validates_presence_of [:email, :password, :password_confirmation, :first_name, :last_name]
  validates_confirmation_of :password

  def full_name
    first_name + " " + last_name
  end
end