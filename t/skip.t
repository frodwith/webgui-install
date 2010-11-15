use strict;
use warnings;

use Test::More tests => 2;
require WebGUI::Test::Skip;

sub fakeloader {
    my $filename = pop; 
    if ($filename eq 'WebGUI/Test.pm') {
        my $str = 'package WebGUI::Test; 1;';
        open my $fh, '<', \$str;
        return $fh;
    }
    return;
}

sub wrap_loader {
    my ($import, $block) = @_; 
    local @INC = (\&fakeloader, @INC);
    no warnings 'redefine';
    no warnings 'once';
    local *WebGUI::Test::import = $import;
    &$block();
}

wrap_loader(sub { die 'horribly' }, sub {
    ok WebGUI::Test::Skip::should_skip(), 'skips on die';
});

wrap_loader(sub { 1 }, sub {
    ok !WebGUI::Test::Skip::should_skip(), 'does not skip on success';
});
