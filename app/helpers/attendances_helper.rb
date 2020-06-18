module AttendancesHelper
  
  # 出社・退社ボタン
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end
  
  # 在社時間
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
    # 時間外時間
  def working_overtimes(designated_work_end_time, scheduled_end_time, worked_on)
    designated_work_end_time = designated_work_end_time.change(year: worked_on.year, month: worked_on.month, day: worked_on.day)
    format("%.2f", (((scheduled_end_time - designated_work_end_time) / 60) / 60.0))
  end
  
  # 残業申請が自分に来ているか
  def overtime_notice
    Attendance.where(overtime_status: "申請中", confirmation: @user.name)
  end
  
  # 勤怠申請が自分に来ているか
  def attendance_notice
    Attendance.where(attendance_status: "申請中", confirmation: @user.name)
  end
end
