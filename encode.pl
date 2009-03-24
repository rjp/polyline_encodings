use Data::Dumper;
use Math::BigFloat lib => 'FastCalc';

Math::BigFloat->accuracy(8);

$main::DEBUG=0;

sub x {
    return; # if ($main::DEBUG == 0) { return };
    my $bits = shift;
    my $info = shift;
    print unpack("B*", pack("N", $bits)), " | $bits | $info\n";
}

sub x5 {
    return; # if ($main::DEBUG == 0) { return };
    my $bits = shift;
    my $info = shift;
    my $s = unpack("B*", pack("N", $bits)), " $info\n";
    my $t = join(' ', split(/(.....)/, substr($s, -30)));
    print $t," | $bits | $info\n";
}

sub z {
    return; # if ($main::DEBUG == 0) { return };
    my $r = shift;
    print join(',', @$r),"\n";
}

sub encode_number {
    my $point = shift;
    my $encoded = '';


    if ($point == 0) { return chr(63); }

    # multiply by 1e5 and truncate
    my $scaled = int(1e5 * abs($point));
    x5($scaled, "*1e5");

    # if it's negative, invert and pad
    if ($point < 0) {
        $scaled = $scaled ^ 0xFFFFFFFF;
        x5($scaled, "invert");
        my $bitpoint = 1;
        while ($scaled & $bitpoint) { 
            $scaled = $scaled & ~$bitpoint;
            $bitpoint = $bitpoint << 1;
        }
        $scaled = $scaled ^ $bitpoint;
        x5($scaled, "pad to right");
    }

    # shift the binary value
    $scaled = ($scaled << 1) & 0xFFFFFFFF;
    x5($scaled, "shift left");

    # if it's negative, invert again
    if ($point < 0) {
        $scaled = $scaled ^ 0xFFFFFFFF;
        x5($scaled, "invert again");
    }

    x5($scaled);

    my @chunks = ();
    while ($scaled) { 
        # split into 5 bit chunks
        my $chunk = $scaled & 0x1F;
        # or it with 0x20 to signify followers
        push @chunks, $chunk | 0x20;
        x5($scaled);
        z(\@chunks);
        $scaled = $scaled >> 5;
    }

    z(\@chunks);

    # remove the 0x20 from the last one
    $chunks[-1] = $chunks[-1] & 0x1F;

    z(\@chunks);

    my @chrs = map { chr($_ + 63) } @chunks;
    z(\@chrs);

    $encoded = join('', @chrs);

#    print "en: $point => $encoded\n" if $DEBUG;
    return $encoded;
}

sub encode_point {
    my $lat = shift;
    my $long = shift;

    my $ela = encode_number($lat);
    my $elo = encode_number($long);

    return $ela . $elo;
}

sub encode_points {
    my $polyline = shift;
    my $p_lat = new Math::BigFloat 0;
    my $p_lng = new Math::BigFloat 0;
    my $polyencoded = '';
    my $scale = 10000000;

    foreach my $i (@{$polyline}) {
        my $s_lat = new Math::BigFloat $i->[0];
        my $s_lng = new Math::BigFloat $i->[1];

        my $d_lat = $s_lat - $p_lat;
        my $d_lng = $s_lng - $p_lng;

#        print "($i->[0], $i->[1])-($usp_lat,$usp_lng) = ($p_lat, $p_lng) - ($s_lat, $s_lng) = ($d_lat, $d_lng)\n";
        $polyencoded .= encode_point($d_lat, $d_lng);
        $p_lat = $s_lat;
        $p_lng = $s_lng;
    }
    return $polyencoded;
}

1;
