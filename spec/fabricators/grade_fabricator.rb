Fabricator(:grade) do
  student { Fabricate(:user) }
  assignment
  points { rand(20) }
end
