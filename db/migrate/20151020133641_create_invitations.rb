class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :course_id
      t.string :email
      t.string :token
      t.timestamps
    end
  end
end
