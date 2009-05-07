# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Encode-Polylines-XS.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 3 };
use Encode::Polylines::XS;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

Encode::Polylines::XS::hello();
# av_len actually returns $#, not the length of the array
ok(Encode::Polylines::XS::encode([38.5, -120.2]), "_p~iF~ps|U");
ok(Encode::Polylines::XS::encode([38.5, -120.2, 40.7, -120.95, 43.252, -126.453]),
    '_p~iF~ps|U_ulLnnqC_mqNvxq`@');
