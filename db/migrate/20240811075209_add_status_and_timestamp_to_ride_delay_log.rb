class AddStatusAndTimestampToRideDelayLog < ActiveRecord::Migration[7.2]
  def change
    add_column :ride_delay_logs, :status, :integer, default: 0
    add_column :ride_delay_logs, :timestamp, :text
  end
end
