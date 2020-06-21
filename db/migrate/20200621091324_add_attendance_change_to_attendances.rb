class AddAttendanceChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_change, :boolean
  end
end
