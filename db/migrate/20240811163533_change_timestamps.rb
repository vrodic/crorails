class ChangeTimestamps < ActiveRecord::Migration[7.2]
  def up
    change_column :rides, :created_at, :datetime
    change_column :rides, :updated_at, :datetime
    change_column :ride_delay_logs, :created_at, :datetime
  end

  def down
    change_column :rides, :created_at, :text
    change_column :rides, :updated_at, :text
    change_column :ride_delay_logs, :created_at, :text
  end
end
