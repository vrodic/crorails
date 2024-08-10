class StopTime < ApplicationRecord
  self.primary_key = [:trip_id, :stop_sequence]
  belongs_to :trip, primary_key: :trip_id
  belongs_to :stop
end
