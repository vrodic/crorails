namespace :log_delays do
  desc 'Every 5 minutes'
  task get: :environment do
    Trip.started_trips_from.find_each do |trip|
      next if trip.trip_short_name.length > 4 # Vlak 90030 nije u evidenciji

      last_ride = trip.sync_last_ride
      puts "#{trip.trip_short_name}: #{last_ride.status}, late #{last_ride.minutes_late} min."
    end
  end
end
