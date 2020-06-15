module AttendancesHelper
  
  #出社・退社ボタン
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end
  
  #時間外時間
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  #残業申請が自分に来ているか
  def overtime_notice
    Attendance.where(overtime_status: "申請中", confirmation: @user.name)
  end
    
end
