class Stop < ApplicationRecord
  self.primary_key = :stop_id
  has_many :stop_times, dependent: :destroy
  include Hzpp

  def hzpp_location_id
    REVERSE_LOCS[stop_name.downcase]
  end
end
