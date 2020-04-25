class AddBasicInfo3ToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :work_f_time, :datetime, default: Time.current.change(hour: 16, min: 30, sec: 0)
  end
end
