class ChangeColumnNameInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :professor, :instructor
  end
end
