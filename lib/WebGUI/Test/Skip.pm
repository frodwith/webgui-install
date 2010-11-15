package WebGUI::Test::Skip;

use warnings;
use strict;

sub should_skip {
    eval { require WebGUI::Test } or return $@;
    eval { WebGUI::Test->import } or return $@;
    return 0;
}

sub import {
    if (my $msg = should_skip) {
        print "1..0 # WebGUI::Test did not load: $msg\n";
        exit 0;
    }
}

1;
