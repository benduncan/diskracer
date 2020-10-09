#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

my %disk;

$disk{"/dev/sdb"} = "/mnt/gp2";
$disk{"/dev/sdc"} = "/mnt/io1";
$disk{"/dev/sdd"} = "/mnt/io2";
$disk{"/dev/sde"} = "/mnt/sc1";
$disk{"/dev/sdf"} = "/mnt/st1";
$disk{"/dev/sdg"} = "/mnt/standard";
$disk{"/dev/nvme7n1"} = "/mnt/nvme";

print "Setting up environment\n";

if(!$ARGV[0] && !$ARGV[1]) {

print "Usage: init.pl [EFS hostname maxio-burst] [EFS hostname, gp-burst]\n";
exit;

}

my %efs;

$efs{$ARGV[0]} = "/mnt/efs-maxio-burst";
$efs{$ARGV[1]} = "/mnt/efs-gp-burst";

foreach my $mnt (keys %efs) {

my $vol = $efs{$mnt};

if(-e $vol) {
    system("umount $vol");
}

if(!-e $vol) {
    system("mkdir $vol");
}

system("mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $mnt:/ $vol");

}


# If no arguments specified, mount the traditional EBS volumes
foreach my $dev (keys %disk) {

my $diskpath = $disk{$dev};

if(-e $diskpath) {
    system("umount $diskpath");
}

# Ugly, however we want to run fdisk non-interactive.
my $fdisk = `fdisk $dev <<EOF
n
p
1


w
EOF
`;

print $fdisk;

# Next, format as ext4 for benchmarking
system("mkdir $diskpath");
system("mkfs.ext4 $dev");
system("mount $dev $diskpath");

}

# Next, mount a 2GB ramdisk for testing purposes
system("mkdir /mnt/ramdisk");
system("mount -t tmpfs -o size=2g tmpfs /mnt/ramdisk");

