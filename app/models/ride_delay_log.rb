class RideDelayLog < ApplicationRecord
  self.primary_key = %i[ride_id status minutes_late point_name]
  belongs_to :ride

  enum :status, %i[initialized ready moving finished]
end
