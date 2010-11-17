package WebGUI::Install::Module::Test;

use Moose;
extends 'WebGUI::Install::Module';

my %versions;

sub read_current_version {
    my $self = shift; $versions{$self->module}
}

sub write_current_version { 
    my $self = shift;
    $versions{$self->module} = shift;
}

1;
