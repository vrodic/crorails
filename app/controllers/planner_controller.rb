# frozen_string_literal: true

class PlannerController < ApplicationController
  def index
    @sources = UserStopHistory.where(stop_type: 'source').order(updated_at: :desc).map(&:stop) + Stop.order(:stop_name)
    @destinations = UserStopHistory.where(stop_type: 'destination').order(updated_at: :desc).map(&:stop) + Stop.order(:stop_name)
  end

  def show
    @source = Stop.find(params[:source])
    @destination = Stop.find(params[:destination])
    source_history = UserStopHistory.find_by(stop_type: 'source', stop: @source)
    source_history&.touch
    UserStopHistory.create(stop: @source, stop_type: 'source') unless source_history

    destination_history = UserStopHistory.find_by(stop_type: 'destination', stop: @destination)
    destination_history&.touch
    UserStopHistory.create(stop: @destination, stop_type: 'destination') unless destination_history

    time = Time.zone.parse(params[:date])
    time ||= Time.now.getlocal
    time_str = time.strftime('%H:%M')
    time_str = '00:00' if params[:all_today] == '1'
    weekday = time.strftime('%A')
    date = time.strftime('%Y%m%d')

    sql = <<~SQL
      SELECT stop_times.arrival_time departure_time, destination_times.arrival_time destination_time, stop_times.trip_id, trips.trip_short_name
      FROM trips
      JOIN calendar ON trips.service_id = calendar.service_id  AND '#{date}' BETWEEN start_date AND end_date AND #{weekday}=1
      JOIN stop_times ON trips.trip_id=stop_times.trip_id
      JOIN stop_times destination_times ON destination_times.trip_id=stop_times.trip_id
      JOIN stops destinations ON destinations.stop_id=destination_times.stop_id
      JOIN stops ON stops.stop_id =stop_times.stop_id
      WHERE  stop_times.departure_time > '#{time_str}' AND
        stops.stop_id='#{@source.stop_id}' AND
        destinations.stop_id = '#{@destination.stop_id}' AND
        destination_times.stop_sequence > stop_times.stop_sequence
      ORDER BY stop_times.arrival_time ASC;
    SQL

    @trips = StopTime.connection.select_all(sql).to_a
  end

  def delays
    @trip = Trip.find(params[:trip_id])
    @source = Stop.find(params[:source])
    @destination = Stop.find(params[:destination])
    @rides = Ride.joins(:trip).where(trip: { trip_short_name: @trip.trip_short_name })
    @last_ride = @trip.sync_last_ride(wait: false) if Trip.started_trips_from.where(trip_id: @trip).exists?
  end

  def delay_logs
    @ride = Ride.find(params[:ride])
  end
end
