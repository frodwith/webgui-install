use warnings;
use strict;

use Test::More tests => 6;
use WebGUI::Install::Module;

my $session = bless {}, 'WebGUI::Session';
my $module = WebGUI::Install::Module->new($session, 'Test');

# A bit silly perhaps.
is $module->target_version, '0.03';
is $module->target_version('0'), 0;
is $module->target_version('0.01'), '0.01';
is $module->target_version('0.02'), '0.02';
is $module->target_version('0.03'), '0.03';
is $module->target_version('0.04'), '0.04';
