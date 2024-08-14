# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_08_14_104932) do
  create_table "agency", id: false, force: :cascade do |t|
    t.text "agency_id"
    t.text "agency_name"
    t.text "agency_url"
    t.text "agency_timezone"
    t.text "agency_lang"
    t.text "agency_phone"
    t.text "agency_email"
  end

  create_table "calendar", id: false, force: :cascade do |t|
    t.text "service_id"
    t.text "start_date"
    t.text "end_date"
    t.text "monday"
    t.text "tuesday"
    t.text "wednesday"
    t.text "thursday"
    t.text "friday"
    t.text "saturday"
    t.text "sunday"
    t.index ["service_id"], name: "index_calendar_on_service_id", unique: true
  end

  create_table "gtfs_metadata", id: false, force: :cascade do |t|
    t.text "tablename"
    t.text "imported_at"
    t.text "cleaned"
  end

  create_table "ride_delay_logs", id: false, force: :cascade do |t|
    t.integer "ride_id"
    t.text "point_name"
    t.datetime "created_at"
    t.integer "minutes_late"
    t.integer "status", default: 0
    t.datetime "timestamp"
  end

  create_table "rides", force: :cascade do |t|
    t.text "trip_id"
    t.text "trip_short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "end_time"
    t.integer "status", default: 0
    t.integer "minutes_late"
  end

  create_table "routes", id: false, force: :cascade do |t|
    t.text "route_id"
    t.text "agency_id"
    t.text "route_short_name"
    t.text "route_long_name"
    t.text "route_desc"
    t.text "route_type"
    t.index ["route_id"], name: "route_idx", unique: true
  end

  create_table "stop_times", id: false, force: :cascade do |t|
    t.text "trip_id"
    t.text "arrival_time"
    t.text "departure_time"
    t.text "stop_id"
    t.integer "stop_sequence"
    t.text "pickup_type"
    t.text "drop_off_type"
    t.index ["stop_id"], name: "st_stop_idx"
    t.index ["trip_id", "stop_id"], name: "stop_times_idx"
    t.index ["trip_id", "stop_sequence"], name: "index_stop_times_on_trip_id_and_stop_sequence"
    t.index ["trip_id"], name: "st_trip_idx"
  end

  create_table "stops", id: false, force: :cascade do |t|
    t.text "stop_id"
    t.text "stop_name"
    t.text "stop_lat"
    t.text "stop_lon"
    t.index ["stop_id"], name: "stop_idx", unique: true
  end

  create_table "trips", id: false, force: :cascade do |t|
    t.text "route_id"
    t.text "service_id"
    t.text "trip_id"
    t.text "trip_headsign"
    t.text "trip_short_name"
    t.text "direction_id"
    t.text "block_id"
    t.text "shape_id"
    t.text "bikes_allowed"
    t.text "wheelchair_accessible"
    t.index ["route_id", "direction_id"], name: "route_dir_idx"
    t.index ["service_id"], name: "index_trips_on_service_id"
    t.index ["shape_id"], name: "t_shape_idx"
    t.index ["trip_id"], name: "trip_idx", unique: true
  end

  create_table "user_stop_histories", force: :cascade do |t|
    t.integer "user_id"
    t.string "stop_id"
    t.string "stop_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
