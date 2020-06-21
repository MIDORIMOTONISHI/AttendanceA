class AddChangeAttendanceToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_started_at, :datetime
    add_column :attendances, :change_finished_at, :datetime
  end
end
