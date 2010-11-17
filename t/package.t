use WebGUI::Test::Skip;
use WebGUI::Test;
use WebGUI::Install::Package;
use WebGUI::Asset;
use WebGUI::VersionTag;
use File::Temp qw(tempdir);
use File::Copy qw(move);
use Test::More tests => 5;
use Test::MockObject::Extends;
use Try::Tiny;
use Exception::Caught;

my $session = WebGUI::Test->session;

my $import       = WebGUI::Asset->getImportNode($session);
my $dir          = tempdir();
my $package_path = "$dir/the-shawshank-redemption.wgpkg";
my $child_id;

my $collateral = Test::MockObject::Extends->new(
    WebGUI::Install::Package->new(
        session => $session,
        module  => 'WebGUI::Install',
    )
)->mock(
    resolve_path => sub { $package_path }
);

{
    my $child = $import->addChild({
            className => 'WebGUI::Asset::Wobject::Article',
            title     => 'The Shawshank Redemption',
        }
    );
    WebGUI::Test->addToCleanup($child);
    my $storage = $child->exportPackage();
    $child_id = $child->getId;
    $child->purge();
    my $path = $storage->getPath($storage->getFiles->[0]);
    move($path, $package_path);
    $storage->delete();
};

sub asset_by_id {
    my $id = shift;
    my $class = 'WebGUI::Asset';
    my $method = $class->can('newById') ? 'newById' : 'new';
    print STDERR "t\n";
    try { $class->$method($session, $id) }
    catch {
        return undef if caught('WebGUI::Error::InvalidParam');
        rethrow;
    };
}

my $a = asset_by_id($child_id);
ok(!$a, 'before addPackage, the asset is gone');
$collateral->add_package($package_path);
$a = asset_by_id($child_id);
ok $a, 'got something by id';
isa_ok $a, 'WebGUI::Asset';
is $a && $a->get('title'), 'The Shawshank Redemption', 'even the right one';
$collateral->remove_package($package_path);
$a = asset_by_id($child_id);
ok(!$a, 'and after delPackage, it is gone again') or $a->purge();
unlink $package_path;

__END__
addPackage(package, filename)
    import the package at (sharedir/filename) into webgui
delPackage(package, filename)
    scan package for asset/revisions
    remove those revisions if they exist

addExtras(path, targetpath?)
    symlink sharedir/path to into session->extradir/targetpath||path
    
delExtras(targetpath)
    unlink same
