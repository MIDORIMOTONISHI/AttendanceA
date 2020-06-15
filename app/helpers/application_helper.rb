module ApplicationHelper
  
  # ページごとにタイトルを返す
  def full_title(page_name = "")
    base_title = "勤怠システム"
    if page_name.empty?
      base_title
    else
      page_name + " | " + base_title
    end
  end
  
  def working_overtimes(designated_work_end_time, scheduled_end_time, worked_on)
    designated_work_end_time = designated_work_end_time.change(year: worked_on.year, month: worked_on.month, day: worked_on.day)
    format("%.2f", (((scheduled_end_time - designated_work_end_time) / 60) / 60.0))
  end
end
