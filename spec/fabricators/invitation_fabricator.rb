Fabricator(:invitation) do
  email { Faker::Internet.email }
  token { SecureRandom.urlsafe_base64 }
  course
end
