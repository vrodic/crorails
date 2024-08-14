class FillTripShortNames < ActiveRecord::Migration[7.2]
  def up
    execute "UPDATE rides SET trip_short_name=(select trip_short_name from trips where trips.trip_id=rides.trip_id limit 1);"
  end
end
