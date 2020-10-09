#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use Time::HiRes qw( time );

print "vol,type,time\n";

foreach('/mnt/nvme', '/mnt/gp2', '/mnt/io1','/mnt/io2', '/mnt/sc1', '/mnt/st1', '/mnt/standard', '/mnt/efs-gp-burst', '/mnt/efs-maxio-burst', "/mnt/ramdisk")
 {

my $vol = $_;

if(!-e "$vol/taxi") {
system("mkdir $vol/taxi");
}

# Delete exiting taxi.db if it already exists
if(-e "$vol/taxi/taxi.db") {
unlink("$vol/taxi/taxi.db");
}

chdir("$vol/taxi");

system("sqlite3 taxi.db < /mnt/ramdisk/schema.sql");

benchmark_sqlite_vol($vol, "", "/mnt/ramdisk/import.sql", "insert");

# read
benchmark_sqlite_vol($vol, "select passenger_count, sum(total_amount) from trips group by passenger_count", "", "select_passenger_count_group");

benchmark_sqlite_vol($vol, "select count(pu_location_id) from trips", "", "select_count_pu_location_id");

benchmark_sqlite_vol($vol, "select fare_amount, tip_amount from trips where fare_amount > 100 order by tip_amount desc limit 25", "", "select_tip_amount_top25");

# read/write
benchmark_sqlite_vol($vol, "update trips set vendor_id=3 where vendor_id=2", "", "update_trips_vendor_id");

benchmark_sqlite_vol($vol, "delete from trips where vendor_id=3", "", "delete_trips_vendor_id_3");

unlink("$vol/taxi/taxi.db");

}

sub benchmark_sqlite_vol {
my $vol = $_[0];
my $cmd = $_[1];
my $file = $_[2];
my $type = $_[3];

my $output;

my $start = time();

if(!$cmd) {
    $output = `sqlite3 taxi.db < $file 2>&1`;
} else {
    $output = `sqlite3 -echo --cmd '$cmd;' taxi.db < /mnt/ramdisk/exit.sql 2>&1`;
}

my $end = time();
my $runtime = sprintf("%.16s", $end - $start);

print "$vol, $type, $runtime\n";
}