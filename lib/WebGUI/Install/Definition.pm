package WebGUI::Install::Definition;

# ABSTRACT: DSL for creating WebGUI::Install Definition modules

my %packages;

sub pkg_hash {
    my $pkg = shift;
    $packages{$pkg} ||= {};
}

sub setter {
    my $name = shift;
    return sub {
        my $pkg = shift;
        return sub {
            my ($version, $code) = @_;
            pkg_hash($pkg)->{$version}->{$name} = $code;
        };
    };
}

use Sub::Exporter -setup => {
    exports => [
        upgrade      => setter('upgrade'),
        downgrade    => setter('downgrade'),
        version_info => sub {
            my $pkg = shift;
            return sub { pkg_hash($pkg) }
        },
    ],
    groups => {
        default => [qw(upgrade downgrade version_info)],
    }
};

1;
