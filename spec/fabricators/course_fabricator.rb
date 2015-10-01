Fabricator(:course) do
  title { Faker::Lorem.words(3).join(" ")}
  location { Faker::Lorem.words(2).join(" ")}
  code { Faker::Number.hexadecimal(4)}
  meeting_days [1, 3, 5]
  start_time { "#{rand(1..5)}:00PM" }
  end_time { "#{rand(1..12)}:50PM" }
end
