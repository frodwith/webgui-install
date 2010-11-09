{
    package TestModule;
    use Moose;
    extends 'WebGUI::Install::Module';

    my $version = '0';
    sub read_current_version { $version }
    sub write_current_version { $version = shift }
}

my ($first, $second);

{
    package WebGUI::Install::Extension::Fantastic;

    use WebGUI::Install::Extension;

    my %info = (
        '0.01' => {
            upgrade => sub { $first = 1 },
            downgrade => sub { undef $first },
        },
        '0.03' => {
            upgrade => sub { $second = 1 },
            downgrade => sub { undef $second },
        },
    );
    sub version_info { \%info }
}

package main;
use Test::More;
use WebGUI::Install::Module;

# Hopefully we keep session from being used at all. We can mock stuff with
# Test::MockObject later if we need to.
my $session = bless {}, 'WebGUI::Session';
my $module = TestModule->new($session, 'Fantastic');

sub test_version {
    my ($v, $f, $s) = @_;
    $module->up_or_downgrade($v);
    is $first, $f, "$v: first";
    is $second, $s, "$v: second";
    is $module->current_version, $v, "$v: version";
}
ok !defined $first;
ok !defined $second;
test_version '0.02' => 1, undef;
test_version 0 => undef, undef;
test_version '0.03', 1, 1;
test_version '0.01' => 1, undef;
test_version '0' => undef, undef;
test_version '0.01' => 1, undef;
done_testing;
