class ChangeInstructorIdName < ActiveRecord::Migration
  def change
    rename_column :courses, :instructor_id, :user_id
  end
end
