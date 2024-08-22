class StatsController < ApplicationController
  def delays
    @stop = Stop.find(params[:stop]) if params[:stop].present?
    @stops = ([@stop] + UserStopHistory.order(updated_at: :desc).map(&:stop) + Stop.order(:stop_name)).uniq.compact

    @date = params[:date] if params[:date].present?
    @date ||= Time.zone.now.strftime("%Y-%m-%d")

    @delays = late_rides
    @delays = @delays.where(trip_id: @stop.stop_times.pluck(:trip_id)) if @stop.present?

    @delays = @delays.where("created_at >= ? AND created_at <= ?", @date, Time.zone.parse(@date).end_of_day) if @date
    @delays = @delays.where(status: params[:status].to_sym) if params[:status]
    @delays = @delays.order(updated_at: :desc)
  end

  private

  def late_rides
    Ride.includes(trip: [:route]).where("minutes_late > 0")
  end
end
