class Stop < ApplicationRecord
  self.primary_key = :stop_id
  has_many :stop_times
end
