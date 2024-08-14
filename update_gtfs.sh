# https://github.com/vrodic/gtfs-sqlite
 ./gtfs-sqlite http://www.hzpp.hr/Media/Default/GTFS/GTFS_files.zip
 # copy tables from this db to main db, dont touch ride* tables

 # normalize times for sqlite sorts and comparisons to work
 # UPDATE stop_times SET departure_time= substr('00000000'||departure_time,-8), arrival_time = substr('00000000'||arrival_time,-8)
