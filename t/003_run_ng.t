#!/usr/bin/perl
use strict;
use warnings;
use Test::Mock::ExternalCommand;
use Nagios::Plugin::Solaris::CheckRAIDctl;
use t::util;

use Test::More;
$ARGV[0]="--volume=c1t0d0";
my $m = Test::Mock::ExternalCommand->new();
my $raidctl_string = <<EOM;
Volume                  Size    Stripe  Status   Cache  RAID
        Sub                     Size                    Level
                Disk
----------------------------------------------------------------
c1t0d0                  135.9G  N/A     DEGRADE  N/A    RAID1
                0.0.0   135.9G          GOOD
                0.1.0   135.9G          GOOD
EOM

$m->set_command('raidctl', $raidctl_string);

my $r = Nagios::Plugin::Solaris::CheckRAIDctl->new( raidctl => 'raidctl' );
is($r->_volume, 'c1t0d0');
is($r->_raid_status, 'DEGRADE');

eval {
    $r->run();
};
is($@, "raidctl CRITICAL - RAID STATUS IS DEGRADE\n");

done_testing();
