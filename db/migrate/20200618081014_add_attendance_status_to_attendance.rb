class AddAttendanceStatusToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_status, :string
  end
end
