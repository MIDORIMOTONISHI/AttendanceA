class AddNumberToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :number, :integer
  end
end
