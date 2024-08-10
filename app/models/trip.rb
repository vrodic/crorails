class Trip < ApplicationRecord
  self.primary_key = :trip_id
  belongs_to :route, primary_key: :route_id

  has_many :stop_times
  has_many :stops, through: :stop_times
  has_many :rides
  belongs_to :calendar, foreign_key: :service_id

  scope :started_trips_from, ->(time = Time.now) {
    time_str = time.strftime("%H:%M")
    weekday = time.strftime("%A")
    date = time.strftime("%Y%m%d")
    joins(:calendar, :route, :stop_times)
    .where(stop_times: { stop_sequence: 1 })
    .where("departure_time < ?", time_str)
    .where("? BETWEEN start_date AND end_date AND #{weekday}=1", date)
  }


  def sync_last_ride
    last_ride = rides.last
    if last_ride && !last_ride.finished?
      last_ride.sync
      return
    end
    debugger

    last_ride = rides.build
    last_ride.sync
  end
end
