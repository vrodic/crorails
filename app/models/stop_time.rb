# frozen_string_literal: true

class StopTime < ApplicationRecord
  self.primary_key = %i[trip_id stop_sequence]
  belongs_to :trip, primary_key: :trip_id
  belongs_to :stop

  def delayed_arrival_time(delay_minutes)
    delay_minutes ||= 0

    (Time.zone.parse(arrival_time) + delay_minutes * 60).strftime('%H:%M')
  end
end
