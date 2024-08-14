class Cleanup < ActiveRecord::Migration[7.2]
  def up
    drop_table :log_rides_stops
  end
end
