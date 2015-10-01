Fabricator(:user) do
  email { Faker::Internet.email }
  password 'password'
  password_confirmation 'password'
  college_id { Faker::Number.number(10) }
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
end

Fabricator(:instructor, from: :user) do
  instructor { true }
end
