namespace :log_delays do
  desc 'Fetch new delays info'
  task get: :environment do
    Ride.deployed.find_each do |ride|
      ride.sync
      ride.touch

      puts "#{ride.trip.trip_short_name}: #{ride.status}, late #{ride.minutes_late} min.,
           checkpoint #{ride.ride_delay_logs.last.timestamp}"
    end

    puts "Checking new rides"

    Trip.started_trips_from.find_each do |trip|
      last_ride = trip.rides.last

      if last_ride && last_ride.updated_at > 5.minutes.ago && last_ride.deployed?
        # puts "Skip deployed last ride #{trip.trip_short_name} #{last_ride.updated_at}"
        next
      end

      next if trip.trip_short_name.in?(['5521'])
      next if trip.trip_short_name.length > 4 # Vlak 90030 nije u evidenciji

      new_last_ride = trip.sync_last_ride
      new_ride = ""
      new_ride = "New ride" if new_last_ride != last_ride
      next if new_last_ride.finished?

      puts "#{new_ride} #{trip.trip_short_name}: #{new_last_ride.status}, late #{new_last_ride.minutes_late} min."
    end
  end

  desc 'Reset ignores'
  task reset_ignores: :environment do
    TrainIgnore.destroy_all
  end

  desc "Cleanup duplicates"
  task cleanup_duplicates: :environment do
    sql = <<~SQL
       DELETE FROM rides WHERE id NOT in (
         SELECT min(ride_id)
         FROM ride_delay_logs
         JOIN rides ON rides.id =ride_id
         GROUP BY "timestamp", trip_short_name
      );
    SQL
    RideDelayLog.connection.execute(sql)

    sql = <<~SQL
        DELETE FROM ride_delay_logs WHERE id NOT IN (
        SELECT min(id) FROM ride_delay_logs rdl
        GROUP BY timestamp, ride_id, point_name
      );
    SQL
    RideDelayLog.connection.execute(sql)
    sql = <<~SQL
        DELETE FROM ride_delay_logs WHERE id IN (
        SELECT ride_delay_logs.id FROM ride_delay_logs
        LEFT JOIN rides ON rides.id=ride_id
        WHERE rides.id IS NULL
      );
    SQL
    RideDelayLog.connection.execute(sql)
  end
end
