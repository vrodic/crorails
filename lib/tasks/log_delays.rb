
namespace :log_delays do
  desc "Every 5 minutes"
  task get: :environment do
    Trip.started_trips_from.find_each do |trip|
      next if trip.todays_ride.finished?
    end
  end
end
