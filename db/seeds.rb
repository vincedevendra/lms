3.times { Fabricate(:course, instructor: instructor) }

Course.all.each do |course|
  19.times { Fabricate(:user) }
  students = User.last(19)
  course.students << students
  5.times { Fabricate(:assignment, course: course)}

  course.assignments.each do |assignment|
    course.students.each do |student|
      Submission.create(student: student, assignment: assignment,
                        submission: File.open("#{Rails.root}/tmp/sample.docx"),
                        submitted_at: Time.now)
    end
  end
end

example_student = Fabricate(:user, email: 'student@example.com')
example_student.courses << Course.all
