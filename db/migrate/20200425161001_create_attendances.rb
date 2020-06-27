class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :company_time
      t.string :note
      t.datetime :scheduled_end_time
      t.datetime :overtime
      t.string :business_process
      t.string :confirmation
      t.string :attendance_confirmation
      t.string :month_confirmation
      t.references :user, foreign_key: true
      t.datetime :change_started_at
      t.datetime :change_finished_at

      t.timestamps
    end
  end
end
