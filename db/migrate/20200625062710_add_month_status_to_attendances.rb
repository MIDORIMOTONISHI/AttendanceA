class AddMonthStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :month_status, :string
  end
end
