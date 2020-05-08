class AddBossToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :boss, :boolean, default: false
  end
end
