class AddIndexToCalendar < ActiveRecord::Migration[7.2]
  def change
    add_index :calendar, :service_id, unique: true
    add_index :trips, :service_id
    add_index :stop_times, %i[trip_id stop_sequence]

    StopTime.where(drop_off_type: "").update_all(drop_off_type: nil) # rubocop:disable Rails/SkipsModelValidations
    StopTime.where(pickup_type: "").update_all(pickup_type: nil) # rubocop:disable Rails/SkipsModelValidations
    Trip.where(block_id: "").update_all(block_id: nil) # rubocop:disable Rails/SkipsModelValidations
    Trip.where(shape_id: "").update_all(shape_id: nil) # rubocop:disable Rails/SkipsModelValidations
    Trip.where(trip_headsign: "").update_all(trip_headsign: nil) # rubocop:disable Rails/SkipsModelValidations
  end
end
