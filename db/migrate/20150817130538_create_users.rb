class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :college_id
      t.boolean :professor
      t.timestamps
    end
  end
end
