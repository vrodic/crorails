class Ride < ApplicationRecord
  belongs_to :trip
  has_many :ride_delay_logs

  enum :status, [ :initialized, :ready, :moving, :finished ]

  def sync
    train_id = trip.trip_short_name
  end

  def get_delay(train_id)
    train_file = "/tmp/hz#{train_id}"

    conn = Faraday.new(
  url: "https://traindelay.hzpp.hr/train/delay?trainId=#{trainId}",
  headers: { "Authorization" => "Bearer #{ENV["HZ_KEY"]}",
  "User-Agent": "okhttp/4.11.0" }
)
    response = conn.get
    File.open(train_file, "w") { |file| file.write(response.body) }
  end
end
