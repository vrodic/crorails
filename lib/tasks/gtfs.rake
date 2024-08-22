require 'zip'

namespace :gtfs do
  desc 'Get new GTFS data'
  task update: :environment do
    content = Faraday.new("https://www.hzpp.hr/Media/Default/GTFS/GTFS_files.zip").get.body
    # content = File.read("/tmp/gtfs/new.zip")
    Zip::InputStream.open(StringIO.new(content)) do |io|
      while (entry = io.get_next_entry)

        # Read into memory
        content = io.read

        case entry.name
        when "calendar.txt"
          Calendar.sync_csv(content, truncate: true)
        when "routes.txt"
          Route.sync_csv(content)
        when "stops.txt"
          Stop.sync_csv(content)
        when "stop_times.txt"
          StopTime.sync_csv(content) do |col|
            col["arrival_time"] = col["arrival_time"].rjust(8, "0")
            col["departure_time"] = col["departure_time"].rjust(8, "0")
            col["stop_sequence"] = Integer(col["stop_sequence"])
          end
        when "trips.txt"
          Trip.sync_csv(content)
        end
      end
    end
  end
end
