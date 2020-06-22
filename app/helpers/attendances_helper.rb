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
end
