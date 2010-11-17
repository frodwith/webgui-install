package WebGUI::Test::Skip;

# ABSTRACT: skip_all if WebGUI::Test can't be loaded

use warnings;
use strict;

sub should_skip {
    eval { require WebGUI::Test } or return $@;
    eval { WebGUI::Test->import } or return $@;
    return 0;
}

sub import {
    my $root = $ENV{WEBGUI_ROOT} || '/data/WebGUI';
    unshift @INC, "$root/lib", "$root/t/lib";
    if (my $msg = should_skip) {
        print "1..0 # Skipped: WebGUI::Test did not load because: $msg\n";
        exit 0;
    }
}

1;
