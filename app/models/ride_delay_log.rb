class RideDelayLog < ApplicationRecord
  self.primary_key = %i[ride_id created_at]
  belongs_to :ride

  enum :status, %i[initialized ready deployed finished]
end
