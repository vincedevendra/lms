class AddBoxViewIdToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :box_view_id, :string
  end
end
