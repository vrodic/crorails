# frozen_string_literal: true

class Ride < ApplicationRecord
  belongs_to :trip
  has_many :ride_delay_logs

  enum :status, %i[initialized ready moving finished]

  def sync(wait: true)
    train_id = trip.trip_short_name
    get_delay(train_id, wait:)
    return if process_delay

    puts "error fetching #{train_id}, retrying"

    sync(wait: wait + 0.1)
  end

  private

  def get_delay(train_id, wait: true)
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
    sleep rand if wait

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
        self.status = :moving
        delay_log.status = :moving
        timestamp = test_moving.strip
      end
      test_delay = return_value(text, 'Kasni')
      next unless test_delay

      min = test_delay.strip
      min.slice! 'min.'
      minutes_late = min.strip
    end
    return false unless timestamp

    delay_log.minutes_late = minutes_late

    timestamp = timestamp.gsub('u ', '').gsub(' sati', '')
    delay_log.timestamp = Time.zone.strptime(timestamp, '%d.%m.%y. %H:%M').utc
    self.minutes_late = minutes_late

    if last_delay_log && (last_delay_log.point_name == delay_log.point_name &&
         last_delay_log.minutes_late == delay_log.minutes_late &&
         last_delay_log.status == delay_log.status && delay_log.timestamp == last_delay_log.timestamp)
      delay_log.destroy
    end
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
