package WebGUI::Install::Package;

# ABSTRACT: Manage installation and removal of WebGUI packages stored in a
# module's share directory.

use namespace::autoclean;

use Moose;
use File::ShareDir qw(module_dir);
use File::Spec;
use Archive::Tar;
use WebGUI::Storage;
use WebGUI::Asset;
use JSON;
use Try::Tiny;
use Exception::Caught;

=attr session

A WebGUI Session. Required.

=cut

has session => (
    is       => 'ro',
    isa      => 'WebGUI::Session',
    required => 1,
);

=attr module

The name of the module whose sharedir will be the base directory in which to
find packages. Required.

=cut

has module => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

=method resolve_path(@paths)

Each element of paths will be split on C</>, and the flattened list of path
components will be concatenated onto your module ShareDir path in a platform
independant way and returned.

=cut

sub resolve_path {
    my ($self, $path) = @_;
    File::Spec->catfile(module_dir($self->module), split('/', $path));
}

=method add_package(@path_components)

Imports the package in the file indicated by @path_components (after passing
through resolve_path)

=cut

sub add_package {
    my $self    = shift;
    my $path    = $self->resolve_path(@_);
    my $session = $self->session;
    my $storage = WebGUI::Storage->createTemp($session);
    my $import  = WebGUI::Asset->getImportNode($session);
    $storage->addFileFromFilesystem($path);
    $import->importPackage( 
        $storage, {
            overwriteLatest    => 1,
            clearPackageFlag   => 1,
            setDefaultTemplate => 1,
        } 
    );
}

=method remove_package(@path_components)

Removes all revisions found in the package  package in the file indicated by
@path_components (after passing through resolve_path)

=cut

sub remove_package {
    my $self    = shift;
    my $path    = $self->resolve_path(@_);
    my $session = $self->session;
    my $json    = JSON->new;
    my $tar     = Archive::Tar->new;
    my $eight   = WebGUI::Asset->can('newById');
    $tar->read($path);
    for my $file ($tar->get_files) {
        next unless $file->name =~ /\.json$/;
        my $data = $json->decode($file->get_content);
        my ($id, $rd, $rev) = @{$data->{properties}}{qw(assetId revisionDate)};
        print STDERR "p $rd\n";
        if ($eight) {
            try { $rev = WebGUI::Asset->newById($session, $id, $rd) }
            catch {
                rethrow unless caught('WebGUI::Error::InvalidParam');
            };
        }
        else {
            $rev = WebGUI::Asset->new($session, $id, undef, $rd);
        }
        $rev->purgeRevision() if $rev;
    }
}

1;

__END__

=head1 SYNOPSIS

    package WebGUI::Install::Definition::MyCoolTemplates;

    use WebGUI::Install::Definition;
    use WebGUI::Install::Package;

    sub getpkg {
        WebGUI::Install::Package->new(
            session => shift,
            module  => __PACKAGE__,
        );
    }

    upgrade '0.04' => sub {
        my $session = shift;
        getpkg($session)->add_package('my-cool-templates.wgpkg');
    };

    downgrade '0.04' => sub {
        my $session = shift;
        getpkg($session)->remove_package('my-cool-templates.wgpkg');
    };
