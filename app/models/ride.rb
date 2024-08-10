class Ride < ApplicationRecord
  belongs_to :trip
  has_many :ride_delay_logs
  
  enum status: [ :initialized, :ready, :moving, :finished ]
end
