# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Encode-Polylines-XS.t'

use Benchmark;
use Data::Dumper;

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 3 };
use Encode::Polylines::XS;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# av_len actually returns $#, not the length of the array
ok(Encode::Polylines::XS::encode([38.5, -120.2, 40.7, -120.95, 43.252, -126.453]),
    '_p~iF~ps|U_ulLnnqC_mqNvxq`@');
ok(Encode::Polylines::XS::encode([38.5, -120.2]), "_p~iF~ps|U");

my @p = ();
while (<DATA>) {
    chomp;
    my ($la, $lo) = split /, /, $_;
    push @p, $la, $lo;
}

print "spiral has ", scalar @p, " points\n";
timethese(-10, {
    spiral => sub { Encode::Polylines::XS::encode(\@p) },
});

@p = ();
open F, "testfile2";
while (<F>) {
    chomp;
    my ($la, $lo) = split /,/, $_;
    push @p, $la, $lo;
}
ok(Encode::Polylines::XS::encode(\@p), '{~yeF~h}gVsfCgomBx{hAt{ZxjH}j_AsudAka@dqn@qxqBb{P}kb@ioz@}kb@|dIkhC}dItxJfxE~sHdhNufQynGhrVjl{@irVg}iL__uz@ysf@ccdf@_{dI}|j_AjhtKqhnc@tf|Aq}`l@mcjK{brl@m`hO_txJg`gCdypN');

__DATA__
40.76711, -73.97918
40.768280000000004, -73.99996
40.753190000000004, -74.00511
40.744350000000004, -74.00561
40.740190000000005, -73.98707
40.74474, -73.96647
40.758390000000006, -73.96356
40.76516, -73.96853
40.76373, -73.98983000000001
40.75124, -73.99412000000001
40.748380000000004, -73.97558000000001
40.761250000000004, -73.97351
40.757870000000004, -73.98604
40.75553, -73.97574
