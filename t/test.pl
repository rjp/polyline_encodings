use Test::More qw(no_plan);

require_ok 'encode.pl';

my $p1;

$p1 = encode_number(-179.9832104);
is($p1, '`~oia@', 'encoding -179.9832104');
# #
$p1 = encode_number(38.5);
is($p1, '_p~iF', 'encoding 38.5');

$p1 = encode_number(-120.2);
is($p1, '~ps|U', 'encoding -120.2');
 
 $p1 = encode_number(2.2);
 is($p1, '_ulL', 'encoding 2.2');

 $p1 = encode_number(2.552);
 is($p1, '_mqN', 'encoding 2.552');

$p1 = encode_number(-0.75);
is($p1, 'nnqC', 'encoding -0.75');

$p1 = encode_number(-5.503);
is($p1, 'vxq`@', 'encoding -5.503');

$p1 = encode_point(38.5, -120.2);
is($p1, '_p~iF~ps|U', 'encoded (38.5, -120.2)');

$p1 = encode_points([[38.5, -120.2], [40.7, -120.95], [43.252, -126.453]]);
is($p1, '_p~iF~ps|U_ulLnnqC_mqNvxq`@', "encoded polyline");

$p1 = encode_points([[-45,-45], [-15,15], [15,-15], [15.00988,-16.47231]]);
is($p1, '~`tqG~`tqG_kbvD_wemJ_kbvD~jbvDw|@|p~G', "encoded polyline");

my @p = ();
while (<DATA>) {
    my ($la, $lo) = split /, /, $_;
    push @p, [$la, $lo];
}
$main::DEBUG=1;
$p1 = encode_points(\@p);
is($p1, 'miywFz`pbMiFz`Ch}Ad_@fv@bB~X{rBm[w_CitAeQii@`^|GbdC`mAxYzP{rBmoA}KbThmArMk_A', 'spiral points');

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
