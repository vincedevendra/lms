class AddSubmissionRequiredToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :submission_required, :boolean
  end
end
