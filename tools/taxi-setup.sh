
#!/bin/bash

if [ -f "/mnt/ramdisk/yellow_tripdata_2018-01.csv" ]
then
	echo "/mnt/ramdisk/yellow_tripdata_2018-01.csv already exists, skipping download."
else
	wget https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2018-01.csv -O /mnt/ramdisk/yellow_tripdata_2018-01.csv

	# Remove the first two lines from the header for sqlite csv import
	sed -i '1,2d' /mnt/ramdisk/yellow_tripdata_2018-01.csv
	
fi

cp sql/schema.sql /mnt/ramdisk/
cp sql/import.sql /mnt/ramdisk/
cp sql/exit.sql /mnt/ramdisk/
