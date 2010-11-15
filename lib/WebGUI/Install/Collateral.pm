package WebGUI::Install::Collateral;

use Moose;
use File::ShareDir qw(module_dir);
use File::Spec;
use Archive::Tar;
use WebGUI::Storage;
use WebGUI::Asset;
use JSON;

has session => (
    is       => 'ro',
    isa      => 'WebGUI::Session',
    required => 1,
);

has module => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub resolve_path {
    my ($self, $path) = @_;
    File::Spec->catfile(module_dir($self->module), split('/', $path));
}

sub add_package {
    my ($self, $filename) = @_;
    my $session = $self->session;
    my $storage = WebGUI::Storage->createTemp($session);
    my $import  = WebGUI::Asset->getImportNode($session);
    $storage->addFileFromFilesystem($self->resolve_path($filename));
    $import->importPackage( 
        $storage, {
            overwriteLatest    => 1,
            clearPackageFlag   => 1,
            setDefaultTemplate => 1,
        } 
    );
}

sub remove_package {
    my ($self, $filename) = @_;
    my $session = $self->session;
    my $json    = JSON->new;
    my $tar     = Archive::Tar->new;
    $tar->read($filename);
    for my $file ($tar->get_files) {
        next unless $file->name =~ /\.json$/;
        my $data = $json->decode($file->get_content);
        my ($id, $rd, $rev) = @{$data->{properties}}{qw(assetId revisionDate)};
        if (WebGUI::Asset->can('newById')) {
            $rev = WebGUI::Asset->newById($session, $id, $rd);
        }
        else {
            $rev = WebGUI::Asset->new($session, $id, undef, $rd);
        }
        $rev->purgeRevision();
    }
}

sub add_extras {
}

sub remove_extras {
}

1;
