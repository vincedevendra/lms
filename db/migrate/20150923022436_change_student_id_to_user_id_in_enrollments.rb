class ChangeStudentIdToUserIdInEnrollments < ActiveRecord::Migration
  def change
    rename_column :enrollments, :student_id, :user_id
  end
end
