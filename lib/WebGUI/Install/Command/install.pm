package WebGUI::Install::Command::install;

use Moose;
use WebGUI::Install::Module;
use Monkey::Patch;

extends 'WebGUI::Install::Command';

sub execute {
    my ($self, $opt, $args) = @_;
    my ($name, $target) = @$args;
    $self->usage_error('Need an extension name') unless $name;

    my $module = WebGUI::Install::Module->new($self->session, $name);
    my @patches = (
        patch_object(
            $module => upgrade => sub {
                my ($upgrade, $self, $from, $to) = @_;
                print "Upgrading: $from => $to\n";
                $self->$upgrade($from, $to);
            }
        ),
        patch_object(
            $module => downgrade => sub {
                my ($downgrade, $self, $from, $to) = @_;
                print "Downgrading: $from => $to\n";
                $self->$downgrade($from, $to);
            }
        ),
    );
    $self->up_or_downgrade($target);
    print "Done.\n";
}

1;
