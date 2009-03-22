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
