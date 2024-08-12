class ChangeDelayTimestamp < ActiveRecord::Migration[7.2]
  def up
    count = 0
    RideDelayLog.where("timestamp LIKE('%sati')").find_each do |delay|
      next unless delay.timestamp

      count += 1
      timestamp = delay.timestamp
      timestamp = timestamp.gsub('u ', '').gsub(' sati', '')
      begin
        delay.update(timestamp: Time.zone.strptime(timestamp, '%d.%m.%y. %H:%M'))
      rescue Date::Error
        Rails.logger.debug "TS: #{timestamp}"
      end
    end
    Rails.logger.debug count

    change_column :ride_delay_logs, :timestamp, :datetime
  end
end
