class RenameCollegeId < ActiveRecord::Migration
  def change
    rename_column :users, :college_id, :student_id
  end
end
