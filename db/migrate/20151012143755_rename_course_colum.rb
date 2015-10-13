class RenameCourseColum < ActiveRecord::Migration
  def change
    rename_column :courses, :user_id, :instructor_id
  end
end
