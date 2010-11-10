my ($upgrade_1, $downgrade_2, $upgrade_4, $downgrade_4)
    = map { sub {} } (1..4);

{
    package TestDefinition;
    use WebGUI::Install::Definition;

    upgrade '0.01' => $upgrade_1;
    downgrade '0.02' => $downgrade_2;
    upgrade '0.04' => $upgrade_4;
    downgrade '0.04' => $downgrade_4;
}

use warnings;
use strict;

use Test::More tests => 1;

is_deeply(
    TestDefinition->version_info, {
        '0.01' => {
            upgrade => $upgrade_1,
        },
        '0.02' => {
            downgrade => $downgrade_2,
        },
        '0.04' => {
            upgrade => $upgrade_4,
            downgrade => $downgrade_4,
        },
    }
);
