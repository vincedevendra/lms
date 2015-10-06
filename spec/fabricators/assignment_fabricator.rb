Fabricator(:assignment) do
  title { Faker::Lorem.word }
  description { Faker::Lorem.paragraph }
  due_date { Faker::Date.between(2.months.ago, Date.today) }
  point_value { [10, 20, 50, 100].sample }
  course
end
