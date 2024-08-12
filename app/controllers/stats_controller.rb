class StatsController < ApplicationController
  def delays
    @stops = UserStopHistory.order(updated_at: :desc).map(&:stop) + Stop.order(:stop_name)

    @stop = Stop.find(params[:stop]) if params[:stop]
    if @stop
      @delays = deployed_late_rides.where(trip_id: @stop.stop_times.pluck(:trip_id))
      @date ||= Time.zone.now.strftime("%Y-%m-%d")
    end

    @delays = @delays.where("created_at > ?", @date) if @date

    @delays ||= deployed_late_rides.where(status: :deployed)
    @delays = @delays.order(minutes_late: :desc)
  end

  private

  def deployed_late_rides
    Ride.includes(trip: [:route]).where("minutes_late > 0")
  end
end
