namespace :log_delays do
  desc 'Every 5 minutes'
  task get: :environment do
    Ride.deployed.find_each do |ride|
      ride.sync
      ride.touch

      puts "#{ride.trip.trip_short_name}: #{ride.status}, late #{ride.minutes_late} min."
    end

    puts "Checking new rides"

    Trip.started_trips_from.find_each do |trip|
      last_ride = trip.rides.last

      if last_ride && last_ride.updated_at > 5.minutes.ago && last_ride.status == :deployed
        puts "Skip deployed last ride #{trip.trip_short_name} #{trip.rides.last_updated_at}"
      end
      next if trip.trip_short_name.length > 4 # Vlak 90030 nije u evidenciji

      last_ride = trip.sync_last_ride
      puts "#{trip.trip_short_name}: #{last_ride.status}, late #{last_ride.minutes_late} min."
    end
  end
end
