use warnings;
use strict;

use Test::More;
use WebGUI::Install::Module::Test;

# Hopefully we keep session from being used at all. We can mock stuff with
# Test::MockObject later if we need to.
my $session = bless {}, 'WebGUI::Session';
my $module = WebGUI::Install::Module::Test->new($session, 'Test');
$module->write_current_version(0);

my $ext = 'WebGUI::Install::Definition::Test';

sub test_version {
    my ($v, $f, $s) = @_;
    $module->up_or_downgrade($v);
    is $ext->first, $f, "$v: first";
    is $ext->second, $s, "$v: second";
    is $module->current_version, $v, "$v: version";
}
ok !defined $ext->first;
ok !defined $ext->second;
test_version '0.02' => 1, undef;
test_version 0 => undef, undef;
test_version '0.03', 1, 1;
test_version '0.01' => 1, undef;
test_version '0' => undef, undef;
test_version '0.01' => 1, undef;
done_testing;
