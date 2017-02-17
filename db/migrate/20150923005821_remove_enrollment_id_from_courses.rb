class RemoveEnrollmentIdFromCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :enrollment_id
  end
end
