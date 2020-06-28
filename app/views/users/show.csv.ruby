require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 出社時間 退社時間)
  csv << column_names
  @attendances.each do |day|
    column_values = [
      l(day.worked_on, format: :short),
      if day.changed_started_at.present? && day.attendance_status == "勤怠編集承認済"
        day.changed_started_at.floor_to(15.minutes).strftime('%H:%M')
      elsif day.started_at.present?
        day.started_at.floor_to(15.minutes).strftime('%H:%M') if day.started_at.present?
      end,
      if day.changed_finished_at.present? && day.attendance_status == "勤怠編集承認済"
        day.changed_finished_at.floor_to(15.minutes).strftime('%H:%M')
      elsif day.finished_at.present?
        day.finished_at.floor_to(15.minutes).strftime('%H:%M') if day.finished_at.present?
      end
    ]
    csv << column_values
  end
end