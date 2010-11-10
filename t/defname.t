use warnings;
use strict;

use Test::More tests => 2;
use WebGUI::Install::Module;

sub trans { WebGUI::Install::Module->definition_name(shift) }

is trans('Foo'), 'WebGUI::Install::Definition::Foo';
is trans('+Something::Else'), 'Something::Else';
