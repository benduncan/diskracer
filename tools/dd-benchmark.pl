
#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

# 'sync' writes any data buffered in memory out to disk.  This can include
# (but is not limited to) modified superblocks, modified inodes, and
# delayed reads and writes.  This must be implemented by the kernel; The
# 'sync' program does nothing but exercise the 'sync' system call.

# The kernel keeps data in memory to avoid doing (relatively slow) disk
# reads and writes.  This improves performance, but if the computer
# crashes, data may be lost or the file system corrupted as a result.  The
# 'sync' command ensures everything in memory is written to disk.

sub sync() {
    system("sync");
}

print '"device","method","filename","bytes","size","seconds","speed","blocksize","count","oflag"' . "\n";

#print "Disk performance utility\n\n";

foreach('/mnt/nvme', '/mnt/gp2', '/mnt/io1','/mnt/io2', '/mnt/sc1', '/mnt/st1', '/mnt/standard', '/mnt/efs-gp-burst', '/mnt/efs-maxio-burst', "/mnt/ramdisk") {
my $disk = $_;
my $i = 0;

for(1 .. 5) {
    my $n = $_;

    my $count = 2**(9-$n);
    my $blocksize = 8 ** $n;

    dd_disk($disk, $i++, $blocksize . "k", $count, "dsync");

}

sync();

}

sub dd_disk {
    my($disk, $file, $bs, $count, $oflag) = @_;
    my($oflagargs, $filename, $output);

    $filename = "$disk/test$file.img";

    if($oflag) {
        $oflagargs = "oflag=$oflag";
    }

    if (-e $filename) {
        unlink($filename);
    }

    # Sync/flush cache
    sync();
    $output = `dd if=/dev/zero of=$filename bs=$bs count=$count $oflagargs 2>&1`;

    #my $dev = find_dev($filename);

    my($size, $sizeH, $copyTime, $speed) = parse_dd($output);
    print "$disk, write, $filename, $size, $sizeH, $copyTime, $speed, $bs, $count, $oflag\n";

    # 2nd step, read the specified file   
    # Enable the drive cache
    #system("hdparm -W1 $dev");
    sync();
    $output = `dd if=$filename of=/dev/zero 2>&1`;
    ($size, $sizeH, $copyTime, $speed) = parse_dd($output);
    print "$disk, read-cache, $filename, $size, $sizeH, $copyTime, $speed, $bs, $count, $oflag\n";

    # Disable the OS cache
    `echo 3 | sudo tee /proc/sys/vm/drop_caches`;
    sync();
    # Disable the drive cache (TBC under EC2/EBS volume)
    #system("hdparm -W0 $dev");
    $output = `dd if=$filename of=/dev/zero 2>&1`;
    ($size, $sizeH, $copyTime, $speed) = parse_dd($output);
    print "$disk, read-nocache, $filename, $size, $sizeH, $copyTime, $speed, $bs, $count, $oflag\n";

    # Remove the file once complete
    if (-e $filename) {
        unlink($filename);
    }


}

sub parse_dd {
    my $output = $_[0];
    $output =~ /(\d+) bytes \((.*?)\) copied, (.*?) s, (.*)/;

    return $1, $2, $3, $4;
}

sub find_dev {
    my $file = $_[0];
    my $dev = `df -P $file | awk 'END{print \$1}'`;

    if($dev eq "127.0.0.1:/") {
        my $dev = `df -P $file | awk 'END{print \$6}'`;
    }

    chomp($dev);
    return $dev;
}


