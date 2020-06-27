class AddMonthChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :month_change, :boolean
  end
end
