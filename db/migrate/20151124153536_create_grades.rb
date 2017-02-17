class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.integer :student_id
      t.integer :assignment_id
      t.float :points
      t.timestamps
    end

    remove_column :submissions, :grade
  end
end
