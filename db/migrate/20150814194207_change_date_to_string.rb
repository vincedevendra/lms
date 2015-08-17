class ChangeDateToString < ActiveRecord::Migration
  def change
    change_column :assignments, :due_date, :string
  end
end
