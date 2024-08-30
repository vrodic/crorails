# frozen_string_literal: true

class Trip < ApplicationRecord
  self.primary_key = :trip_id
  belongs_to :route, primary_key: :route_id

  has_many :stop_times, dependent: :destroy
  has_many :stops, through: :stop_times
  has_many :rides, dependent: :destroy
  belongs_to :calendar, foreign_key: :service_id # rubocop:disable Rails/InverseOf

  scope :started_trips_from, lambda { |time = Time.now.getlocal|
    time_str = time.strftime('%H:%M')
    weekday = time.strftime('%A').downcase
    date = time.strftime('%Y%m%d')
    joins(:calendar, :route, :stop_times)
      .where(stop_times: { stop_sequence: 1 })
      .where('departure_time < ?', time_str)
      .where("calendar.#{weekday}": 1)
      .where("? BETWEEN start_date AND end_date", date)
  }

  def sync_last_ride(unstarted_ignores: true) # rubocop:disable Lint/UnusedMethodArgument
    last_ride = rides.last
    last_ride ||= Ride.where(trip_short_name:).last # changed GTFS
    if last_ride && !last_ride.finished?
      last_ride.sync
      return last_ride
    end

    if last_ride
      last_checkin = last_ride.ride_delay_logs.order(:timestamp).last.timestamp
      today_start = Time.zone.parse("#{Time.now.getlocal.strftime('%Y-%m-%d')} #{stop_times.first.departure_time}")
      last_ride_is_todays = last_checkin > today_start
    end
    if last_ride_is_todays
      return last_ride if last_ride.finished?
    else
      # if unstarted_ignores && TrainIgnore.find_by(id: trip_short_name.to_i)
      #   puts "Ignored #{trip_short_name}"
      #  return last_ride
      # end

      new_ride = rides.build
      new_ride.sync
      if last_ride && new_ride.equal_delay(last_ride.ride_delay_logs.last, new_ride.ride_delay_logs.last)
        new_ride.destroy
        # TrainIgnore.create(id: trip_short_name) if unstarted_ignores
        puts "New ride not started #{trip_short_name}, possible schedule problems"
        return last_ride
      end
      return new_ride
    end

    last_ride.sync
    last_ride
  end
end
