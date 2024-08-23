# frozen_string_literal: true

class Ride < ApplicationRecord
  belongs_to :trip
  has_many :ride_delay_logs

  enum :status, %i[initialized ready deployed finished]

  before_create :set_trip_short_name

  def sync
    train_id = trip.trip_short_name
    @wait ||= 0
    get_delay(train_id)

    return if process_delay

    @wait += 0.1
    puts "error fetching #{train_id}, retrying with #{@wait} second wait after"

    sync
  end

  def equal_delay(old, new_log)
    return true if old && (old.point_name == new_log.point_name &&
    old.minutes_late == new_log.minutes_late &&
    old.status == new_log.status && new_log.timestamp == old.timestamp)

    false
  end

  private

  def set_trip_short_name
    self.trip_short_name = trip.trip_short_name
  end

  def get_delay(train_id)
    # train_file = "/tmp/hz-#{train_id}-#{Time.zone.now.strftime('%Y%m%d')}.html"

    # return File.read(train_file) if File.exist?(train_file)
    #
    Rails.logger.debug "Fetching #{train_id}: #{status}"

    conn = Faraday.new(
      url: "https://traindelay.hzpp.hr/train/delay?trainId=#{train_id}",
      headers: {
        'Authorization' => "Bearer #{ENV['HZ_KEY']}",
        "User-Agent": 'okhttp/4.11.0'
      }
    )
    @response = conn.get
    sleep @wait if @wait.positive?

    # File.open(train_file, 'w') { |file| file.write(response.body) }

    @response.body
  end

  def process_delay
    return true if @response.body.include? "Vlak nije u evidenciji."

    last_delay_log = ride_delay_logs.last
    delay_log = ride_delay_logs.build
    minutes_late = 0
    timestamp = nil

    document = Nokogiri::HTML(@response.body)
    document.css('td').each do |td|
      text = td.text.strip
      test_point = return_value(text, 'Kolodvor: ')
      delay_log.point_name = test_point if test_point
      test_finished = return_value(text, 'Završio vožnju')
      test_ready = return_value(text, 'Formiran')
      test_moving = return_value(text, 'Odlazak')
      test_moving ||= return_value(text, 'Dolazak')
      if test_ready
        self.status = :ready
        delay_log.status = :ready
        timestamp = test_ready.strip # TODO: process this
      end
      if test_finished
        self.status = :finished
        delay_log.status = :finished
        timestamp = test_finished.strip
      end
      if test_moving
        self.status = :deployed
        delay_log.status = :deployed
        timestamp = test_moving.strip
      end
      test_delay = return_value(text, 'Kasni')
      next unless test_delay

      min = test_delay.strip
      min.slice! 'min.'
      minutes_late = min.strip
    end

    unless timestamp
      delay_log.destroy
      return false
    end

    delay_log.minutes_late = minutes_late

    timestamp = timestamp.gsub('u ', '').gsub(' sati', '')
    delay_log.timestamp = Time.zone.strptime(timestamp, '%d.%m.%y. %H:%M').utc
    self.minutes_late = minutes_late

    delay_log.destroy if equal_delay(last_delay_log, delay_log)
    save
  end

  def return_value(text, selector)
    if text.start_with?(selector)
      text.slice! selector
      return text
    end

    false
  end
end
