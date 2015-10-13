class ChangeEnrollmentUserIdColumnName < ActiveRecord::Migration
  def change
    rename_column :enrollments, :user_id, :student_id
  end
end
