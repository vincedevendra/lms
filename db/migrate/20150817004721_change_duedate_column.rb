class ChangeDuedateColumn < ActiveRecord::Migration
  def change
    remove_column :assignments, :due_date
    add_column :assignments, :due_date, :date
  end
end
