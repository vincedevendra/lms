class AddTimestampsToSubmissions < ActiveRecord::Migration
  def change
    add_timestamps :submissions
  end
end
