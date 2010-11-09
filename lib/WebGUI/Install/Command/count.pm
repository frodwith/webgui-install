package WebGUI::Install::Command::count;

use Moose;
extends 'WebGUI::Install::Command';

sub execute {
    my $self = shift;
    my $count = $self->session->db->quickScalar(q{
            SELECT COUNT(*) FROM asset
        }
    );
    print "There are $count assets.\n";
}

1;
