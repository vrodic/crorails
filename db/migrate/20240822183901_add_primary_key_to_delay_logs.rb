class AddPrimaryKeyToDelayLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :ride_delay_logs, :id, :primary_key
  end
end
