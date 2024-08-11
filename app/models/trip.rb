# frozen_string_literal: true

class Trip < ApplicationRecord
  self.primary_key = :trip_id
  belongs_to :route, primary_key: :route_id

  has_many :stop_times
  has_many :stops, through: :stop_times
  has_many :rides
  belongs_to :calendar, foreign_key: :service_id

  scope :started_trips_from, lambda { |time = Time.now.getlocal|
    time_str = time.strftime('%H:%M')
    weekday = time.strftime('%A')
    date = time.strftime('%Y%m%d')
    joins(:calendar, :route, :stop_times)
      .where(stop_times: { stop_sequence: 1 })
      .where('departure_time < ?', time_str)
      .where("? BETWEEN start_date AND end_date AND #{weekday}=1", date)
  }

  def sync_last_ride
    last_ride = rides.last
    if last_ride && !last_ride.finished?
      last_ride.sync
      return last_ride
    end

    if last_ride && Time.new(last_ride.created_at).getlocal.strftime('%Y%m%d') == Time.now.getlocal.strftime('%Y%m%d')
      return last_ride if last_ride.finished?
    else
      last_ride = rides.build
    end

    last_ride.sync
    last_ride
  end
end
