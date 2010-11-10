package WebGUI::Install::Definition::Test;

# We're not using the DSL cause we want to test that separately

my ($first, $second);

sub first { $first }
sub second { $second }

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

1;
