class AddAttendanceTomorrowToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_tomorrow, :boolean
  end
end
