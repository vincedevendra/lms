class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.string :code
      t.string :location
      t.string :meeting_days
      t.string :start_time
      t.string :end_time
      t.text :notes
      t.integer :enrollment_id
      t.integer :instructor_id
      t.timestamps
    end
  end
end
